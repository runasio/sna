defmodule SnaWeb.Auth do

  def current_user(conn) do
    conn.assigns[:auth]
  end

  def check_auth(conn0, _opts) do
    conn = Plug.Conn.assign(conn0, :auth, nil)
    case Plug.Conn.get_session(conn, "auth_token") do
      nil ->
        conn
      token ->
      case SnaWeb.Token.validate_bearer(token) do
        {:ok, %{"email" => email}} ->
          conn
            |> Plug.Conn.assign(:auth, %{email: email})
        {:error, reason} ->
          message = Keyword.get(reason, :message, "")
          conn
            |> Phoenix.Controller.put_flash(:error, "Could not verify token: #{message}")
        _ ->
          conn
            |> Phoenix.Controller.put_flash(:error, "No valid claims in this token")
      end
    end
  end

end

