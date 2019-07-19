defmodule SnaWeb.AuthController do
  use SnaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def email(conn, %{"email" => email}) do
    case SnaWeb.Token.generate_bearer(%{"email" => email}) do
      {:ok, token, _claims} ->
        render(conn, "email.html", email: email, token: token)
      {:error, reason} ->
        conn
          |> put_flash(:error, reason)
          |> redirect(to: "/auth")
          |> halt()
    end
  end

  def email(conn, %{"token" => token}) do
    case SnaWeb.Token.validate_bearer(token) do
      {:ok, %{"email" => _email}} ->
        conn
          |> put_session("auth_token", token)
          |> redirect(to: "/")
          |> halt()
      {:error, reason} ->
        conn
          |> put_flash(:error, "Could not verify token: #{reason}")
          |> redirect(to: "/auth")
          |> halt()
      _ ->
        conn
          |> put_flash(:error, "No valid claims in this token")
          |> redirect(to: "/auth")
          |> halt()
    end
  end

  def logout(conn, _params) do
    conn
      |> delete_session("auth_token")
      |> put_flash(:info, "You are logged out")
      |> redirect(to: "/")
      |> halt()
  end
end
