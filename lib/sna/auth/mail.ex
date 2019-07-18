defmodule Sna.Auth.Mail do

  @moduledoc """

  Sna.Auth.Mail will store email and token. Here the process.

  0. The first step is to start Sna.Auth.Mail worker. You can do it
     manually or with a supervisor. By default, this worker is
     registered with its own name (Sna.Auth.Mail). You can use this
     name to send it messages.

      # starting Sna.Auth.Mail worker in standalone
      iex> {:ok, pid} = Sna.Auth.Mail.start_link()

      # starting the Sna.Auth.Mail supervisor
      iex> {:ok, pid} = Sna.Auth.Mail.Supervisor.start_link()

      # starting Sna.Auth.Mail worker with a timer set to 3000 seconds
      iex> {:ok, pid} = Sna.Auth.Mail.start_link(timer: 3000)

  1. When an user comes and want to use email authentication, an email
     is firstly checked.

      # set a wrong mail and check it
      iex> mail = "wrongmail"
      iex> {:error, reason} = Sna.Auth.Mail |> store(mail)

  2. If the email is valid, a `token` is generated and a timer process
     is launched. `email`, `token` and PID `timer` are stored in the
     ETS table. The caller got the generated token and its
     validity. At the same time, an email is sent to the user with the
     token.

      # set a valid email
      iex> mail = "mymail@localhost"
      iex> {:ok, sometoken, end_date} = Sna.Auth.Mail |> store(mail)

  3. if the token is valid (checked by the user), the mail is stored
     in the underlaying database else, after some minutes, the mail
     and token are rejected.

      # validate a stored token
      iex> {:ok, "mymail@localhost"} = Sna.Auth.Mail |> validate(sometoken)

      # validate a wrong token
      iex> wrong_token = "1234"
      iex> {:error, :wrong_token} = Sna.Auth.Mail |> validate(wrong_token)

  4. after validation, Sna.Auth.Mail process will return the session
     identifier.

  """
  
  use GenServer

  @type token() :: bitstring()
  @type mail() :: bitstring()
  @type state() :: reference()

  @type store() :: bitstring()
  @type message_store() :: {:store, store(), list()}

  @type validate() :: bitstring()
  @type message_validate() :: {:validate, validate()}
  
  @type unvalidate() :: bitstring()
  @type message_unvalidate() :: {:unvalidate, unvalidate()}

  @type check() :: ({mail(), list()} -> :ok | {:error, term()})
 
  @type action() :: ({mail(), token()}  -> :ok | {:error, term()})
  
  @doc """

  start/0 start Sna.Auth.Mail without link.

      iex> Sna.Auth.Mail.start()

  """
  @spec start() :: {:ok, pid()}
  def start(), do: start([])

  @doc """

  start/1 start Sna.Auth.Mail without link but with argument.

      iex> Sna.Auth.Mail.start(timer: 5000)

  """
  @spec start(list()) :: {:ok, pid()}
  def start(args), do: GenServer.start(__MODULE__, args, name: __MODULE__)

  @doc """

  start_link/0 start Sna.Auth.Mail with a link.

      iex> Sna.Auth.Mail.start_link()

  """
  @spec start_link() :: {:ok, pid()}
  def start_link(), do: start_link([])

  @doc """

  start_link/1 start Sna.Auth.Mail with a link.

      iex> Sna.Auth.Mail.start_link(timer: 5000)

  """
  @spec start_link(list()) :: {:ok, pid()}
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @spec init(list()) :: {:ok, state()}
  def init(args) do
    check = Keyword.get(args, :check, fn (_mail) -> :ok end)
    timer = Keyword.get(args, :timer, 30*60*100)
    action = Keyword.get(args, :action, fn (_mail) -> :ok end)
    ets = :ets.new(__MODULE__, [:private])
    ets |> :ets.insert({:check, check})
    ets |> :ets.insert({:timer, timer})
    ets |> :ets.insert({:action, action})
    {:ok, ets}
  end
  
  @spec terminate(term(), state()) :: :ok
  def terminate(_reason, _state) do
    :ok
  end

  @spec handle_call(tuple(), term(), state()) :: {:reply, term(), state()}
  def handle_call({:store, mail}, _from, state), do: handle_store({mail, []}, state)
  def handle_call({:store, mail, opts}, _from, state), do: handle_store({mail, opts}, state)
  def handle_call({:validate, token}, _from, state), do: handle_validate(token, state)
  def handle_call({:validate, token, _opts}, _from, state), do: handle_validate(token, state)
  def handle_call(_data, _from, _state),  do: {:error, :wrong_call}

  @spec handle_cast(tuple(), state()) :: {:noreply, term()}
  def handle_cast({:unvalidate, data}, state), do: handle_unvalidate(data, state)
  def handle_cast({:set, :timer, timer}, state), do: handle_set({:timer, timer}, state)
  def handle_cast({:set, :action, action}, state), do: handle_set({:action, action}, state)
  def handle_cast({:set, :check, check}, state), do: handle_set({:check, check}, state)
  def handle_cast(_data, _state), do: {:error, :wrong_cast}

  @spec handle_store(store(), state()) :: {:reply, term(), state()}
  defp handle_store({mail, opts}, state) do
    # TODO: check mail before doing more
    check = state |> get_check()
    case check.({mail, opts}) do
      :ok ->
        token = generate_token()
        tref = state |> create_timer(token)    
        true = state |> :ets.insert({token, mail, tref, opts})
        _ret = state |> execute_action({mail, token})
        {:reply, {:ok, token}, state}
      _ ->
        {:reply, {:error, :unvalid_mail}, state}
    end
  end

  @spec handle_validate(validate(), state()) :: {:reply, term(), state()}
  defp handle_validate(token, state) do
    case state |> :ets.lookup(token) do
      [] ->
        {:reply, {:error, :unvalid_token}, state}
      [{token, mail, _tref, _opts}] ->
        handle_unvalidate(token, state)
        {:reply, {:ok, mail}, state}
    end
  end

  @spec handle_unvalidate(unvalidate(), state()) :: {:reply, term(), state()}
  defp handle_unvalidate(token, state) do
    state |> :ets.delete(token)
    {:noreply, state}
  end

  @spec handle_set(term(), state()) :: {:noreply, state()}
  defp handle_set(data, state) do
    state |> :ets.insert(data)
    {:noreply, state}
  end
  
  @spec get_check(state()) :: function()
  defp get_check(state) do
    state |> :ets.lookup(:check) |> Keyword.get(:check)
  end

  @spec get_check(state()) :: integer()
  defp get_timer(state) do
    state |> :ets.lookup(:timer) |> Keyword.get(:timer)
  end

  @spec get_action(state()) :: function()
  defp get_action(state) do
    state |> :ets.lookup(:action) |> Keyword.get(:action)
  end

  @spec generate_token() :: bitstring()
  defp generate_token() do
    :crypto.strong_rand_bytes(60) |> Elixir.Base.encode32
  end

  @spec create_timer(state(), bitstring()) :: tuple()
  defp create_timer(state, token) do
    timer = state |> get_timer()
    {:ok, tref} = :timer.apply_after(timer, __MODULE__, :unvalidate, [token])
    tref
  end

  @spec execute_action(state(), tuple()) :: :ok
  defp execute_action(state, args) do
    action = state |> get_action()
    action.(args)
  end
  
  @doc """

  store/1.

      iex> Sna.Auth.Mail.store("mymail@localhost")

  """
  @spec store(bitstring()) :: {:ok, bitstring(), integer()} | {:error, term()}
  def store(mail) do
    __MODULE__ |> store(mail)
  end
  
  @doc """

  store/2.

      iex> pid = Sna.Auth.Mail.whereis(Sna.Auth.Mail)
      iex> Sna.Auth.Mail.store(pid, "mymail@localhost")

  """  
  @spec store(pid(), bitstring()) :: {:ok, bitstring(), integer()} | {:error, term()}
  def store(pid, mail) do
    store(pid, mail, [])
  end

  @doc """

  store/3.

      iex> pid = Sna.Auth.Mail.whereis(Sna.Auth.Mail)
      iex> Sna.Auth.Mail.store(pid, "mymail@localhost", [])

  """
  @spec store(pid(), bitstring(), list()) :: {:ok, bitstring(), integer()} | {:error, term()}
  def store(pid, mail, opts) do
    GenServer.call(pid, {:store, mail, opts})
  end

  @doc """

  validate/1 automatically send message to Sna.Auth.Mail process. The
  first argument is the token previously generated by store/1, store/2
  or store/3.

      iex> Sna.Auth.Mail.validate("mytoken")

  """
  @spec validate(bitstring()) :: {:ok, bitstring()} | {:error, term()}
  def validate(token) do
    __MODULE__ |> validate(token)
  end

  @doc """

  validate/2 send a validate message with no options to a defined process.

      iex> pid = Sna.Auth.Mail.whereis(Sna.Auth.Mail)
      iex> Sna.Auth.Mail.validate(pid, "mytoken")

  """
  @spec validate(pid(), bitstring()) :: {:ok, bitstring()} | {:error, term()}
  def validate(pid, token) do
    validate(pid, token, [])
  end

  @doc """

  validate/3 send a validate message with custom option to a defined process.

      iex> pid = Sna.Auth.Mail.whereis(Sna.Auth.Mail)
      iex> Sna.Auth.Mail.validate(pid, "mytoken", [])

  """
  @spec validate(pid(), bitstring(), list()) :: {:ok, bitstring()} | {:error, term()}
  def validate(pid, token, opts) do
    GenServer.call(pid, {:validate, token, opts})
  end

  @doc """
  
  unvalidate/1 send an unvalidate message to remove a token or an
  email from the ETS store.
  
     iex> token = "somerandomtoken"
     iex> unvalidate(token)
     :ok

  """
  def unvalidate(token) do
    __MODULE__ |> unvalidate(token)
  end

  @doc """

  unvalidate/2 send an unvalidate message to a specific pid.

      iex> token = "somerandomtoken"
      iex> pid = :erlang.whereis(Sna.Auth.Mail)
      iex> pid |> Sna.Auth.Mail.unvalidate(token)
      :ok

  """
  def unvalidate(pid, token) do
    GenServer.cast(pid, {:unvalidate, token})
  end

  @doc """

  set/2 configure key/value (check, action, timer) in Sna.Auth.Mail.

      # set a new timer to 3 seconds
      iex> Sna.Auth.Mail.set(:timer, 3*100)
      :ok

      # set a new check function
      iex> f = fn ({"allowed@mail.com", _}) -> :ok 
                  (_) -> {:error, :wrong_mail}
           end
      iex> Sna.Auth.Mail.set(:check, f)
      :ok

      # set a new action function
      iex> f = fn ({mail, _}) -> IO.inspect(mail) end
      iex> Sna.Auth.Mail.set(:action, f)
      :ok

  """
  def set(key, value) do
    __MODULE__ |> set(key, value)
  end

  @doc """

  set/3 configure key/value (check, action, timer) in Sna.Auth.Mail

      # set a new timer to 3 seconds
      iex> Sna.Auth.Mail |> Sna.Auth.Mail.set(:timer, 3*100)
      :ok

      # set a new check function
      iex> f = fn ({"allowed@mail.com", _}) -> :ok 
                  (_) -> {:error, :wrong_mail}
           end
      iex> Sna.Auth.Mail |> Sna.Auth.Mail.set(:check, f)
      :ok

      # set a new action function
      iex> f = fn ({mail, _}) -> IO.inspect(mail) end
      iex> Sna.Auth.Mail |> Sna.Auth.Mail.set(:action, f)
      :ok


  """
  def set(pid, key, value) do
    pid |> GenServer.cast({:set, key, value})
  end
end
