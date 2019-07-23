defmodule SnaWeb.ProviderOAuthController do
  use SnaWeb, :controller

  @spec strategy_options(Sna.Repo.Provider.t) :: Keyword.t
  defp strategy_options(%{ strategy: "github" } = _provider) do
    [
      default_scope: "user",
      # TODO, this is not configurable here yet:
      # client_id:     provider.provider_info.consumer_key,
      # client_secret: provider.provider_info.consumer_secret,
    ]
  end

  @spec provider_options(Plug.Conn.t, Sna.Repo.Provider.t) :: { module, Keyword.t }
  defp provider_options(conn, provider) do
    import SnaWeb.Router.Helpers

    module = Application.get_env(:sna, :oauth_providers)
      |> Keyword.get(String.to_atom(provider.strategy))

    options = strategy_options(provider)
      |> Keyword.put(:request_path,  provider_o_auth_path(conn, :request, provider.name))
      |> Keyword.put(:callback_path, provider_o_auth_path(conn, :callback, provider.name))

    {module, options}
  end

  @spec request(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def request(conn, %{"provider_name" => provider_name}) do
    provider = Sna.Repo.Provider.get(provider_name)
    conn
      |> ueberauth_run_request(provider_name, provider_options(conn, provider))
  end

  @spec callback(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def callback(conn, %{"provider_name" => provider_name} = params) do
    provider = Sna.Repo.Provider.get(provider_name)
    conn
      |> ueberauth_run_callback(provider_name, provider_options(conn, provider))
      |> handle_callback(params, provider)
  end

  #spec handle_callback(Plug.Conn.t, Plug.Conn.params, Sna.Repo.Provider.t) :: Plug.Conn.t
  defp handle_callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params, _provider) do
    conn
      |> put_flash(:error, "Failed to authenticate.")
      |> redirect(to: "/")
  end

  #spec handle_callback(Plug.Conn.t, Plug.Conn.params, Sna.Repo.Provider.t) :: Plug.Conn.t
  defp handle_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params, provider) do
    %{email: user_email} = SnaWeb.Auth.current_user(conn)
    user = Sna.Repo.User.get_by_email(user_email)
    case Sna.Repo.get_by(Sna.Repo.Token, [user_id: user.id, provider_id: provider.id]) do
      nil  -> %Sna.Repo.Token{user_id: user.id, provider_id: provider.id}
      post -> post
    end
      |> Sna.Repo.Token.changeset(%{
        user_id: user.id,
        provider_id: provider.id,
        token: auth.credentials.token,
        token_secret: auth.credentials.secret,
        retention: auth.credentials.expires_at,
      })
      |> Sna.Repo.insert_or_update()
    conn
      |> put_flash(:info, "Connected.")
      |> redirect(to: "/")
  end

  # Reimplements Ueberauth.build_strategy_options and option post-processing in
  # Ueberauth.run
  @spec ueberauth_options(Plug.Conn.t, binary, module, Keyword.t) :: Plug.Conn.t
  defp ueberauth_options(conn, provider_name, module, options) do
    # Ueberauth.build_strategy_options
    options = %{
      strategy:         module,
      strategy_name:    provider_name,
      request_path:     String.replace_trailing(Keyword.get(options, :request_path), "/", ""),
      callback_path:    Keyword.get(options, :callback_path),
      callback_methods: Enum.map(Keyword.get(options, :callback_methods, ["GET"]), &String.upcase(to_string(&1))),
      options:          options,
      callback_url:     Keyword.get(options, :callback_url),
      callback_params:  Keyword.get(options, :callback_params)
    }

    # Ueberauth.run
    to_request_path = Path.join(["/", conn.script_name, options.request_path])
    to_callback_path = Path.join(["/", conn.script_name, options.callback_path])
    to_options = %{options | request_path: to_request_path, callback_path: to_callback_path}
    conn
      |> Plug.Conn.put_private(:ueberauth_request_options, to_options)
  end

  # Reimplements Ueberauth.run with :run_request
  @spec ueberauth_run_request(Plug.Conn.t, binary, {module, Keyword.t}) :: Plug.Conn.t
  defp ueberauth_run_request(conn, name, {module, options}) do
    conn
      |> ueberauth_options(name, module, options)
      |> Ueberauth.Strategy.run_request(module)
  end

  # Reimplements Ueberauth.run with :run_callback
  @spec ueberauth_run_callback(Plug.Conn.t, binary, {module, Keyword.t}) :: Plug.Conn.t
  defp ueberauth_run_callback(conn, name, {module, options}) do
    conn
      |> ueberauth_options(name, module, options)
      |> Ueberauth.Strategy.run_callback(module)
  end
end
