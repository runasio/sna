defmodule Sna.Auth.Mail do

  @moduledoc """

  Sna.Auth.Mail will store email and token:

  1. when an user comes and want to use email authentication, an email
     is firstly checked.

  2. if the mail is valid, a token is generated and the email is
     stored temporarily in the ETS cache. A timer process is started
     for some minutes.

  3. if the token is valid (checked by the user), the mail is stored
     in the underlaying database else, after some minutes, the mail
     and token are rejected.

  4. after validation, Sna.Auth.Mail process will return the session
     identifier.

  """
  
  use GenServer

  def start_link(), do: start_link([])
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(_args), do: {:ok, :ets.new(__MODULE__, [:private])}

  def terminate(_reason, _state), do: :ok
  
  def handle_call(_data, _from, _state) do
    {:error, :wrong_call}
  end

  def handle_cast(_data, _state) do
    {:error, :wrong_cast}
  end

end
