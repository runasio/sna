defmodule SnaWeb.Auth do
  require Logger

  @type user :: %{
    email: String.t
  }

  @spec current_user(Plug.Conn.t) :: user | nil
  def current_user(conn) do
    conn.assigns[:auth]
  end

  @spec check_auth(Plug.Conn.t, any) :: Plug.Conn.t
  def check_auth(conn, _opts) do
    import Phoenix.Controller
    import Plug.Conn

    conn = assign(conn, :auth, nil)
    case get_session(conn, "auth_token") do
      nil ->
        conn
      token -> case SnaWeb.Token.validate_bearer(token) do
        {:ok, %{"email" => email}} ->
          Logger.debug("SnaWeb.Auth.check_auth/2: email #{email}")
          conn
            |> assign(:auth, %{email: email})
        {:error, reason} ->
          Logger.debug("SnaWeb.Auth.check_auth/2: error #{inspect(reason)}")
          conn
            |> put_flash(:error, SnaWeb.Token.error_message("Could not verify token", reason))
        _ ->
          Logger.debug("SnaWeb.Auth.check_auth/2: no claims in #{token}")
          conn
            |> put_flash(:error, "No valid claims in this token")
      end
    end
  end

  @spec ensure_auth(Plug.Conn.t, any) :: Plug.Conn.t
  def ensure_auth(conn, _opts) do
    import Phoenix.Controller
    case current_user(conn) do
      nil ->
        Logger.debug("SnaWeb.Auth.ensure_auth/2: No current user, redirect to log-in page")
        conn
          |> put_flash(:error, "You need to log-in")
          |> redirect(to: "/auth/")
          |> Plug.Conn.halt()
      _ ->
        conn
    end
  end
end

