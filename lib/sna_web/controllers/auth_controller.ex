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

  def email(conn, params = %{"token" => token}) do
    case [SnaWeb.Token.validate_bearer(token), params] do
      [{:ok, %{"email" => email}}, %{"login" => login}] ->
        inserted = Sna.Repo.User.insert(%{
          email: email,
          login: login,
          admin: false,
        })
        case inserted do
          {:ok, _} ->
            conn
              |> put_session("auth_token", token)
              |> redirect(to: "/")
              |> halt()
          {:error, %{errors: [ email: { _, [ constraint: :unique, constraint_name: _ ] } ]}} ->
            conn
              |> put_flash(:error, "You already registered")
              |> redirect(to: "/")
              |> halt()
          {:error, errors} ->
            errors = Ecto.Changeset.traverse_errors(errors, fn {msg, opts} ->
              Enum.reduce(opts, msg, fn {key, value}, acc ->
                String.replace(acc, "%{#{key}}", to_string(value))
              end)
            end)
            conn
              |> render("first-login.html", token: token, email: email, errors: errors)
        end
      [{:ok, %{"email" => email}}, _] ->
        if Sna.Repo.User.email_exists(email) do
          conn
            |> put_session("auth_token", token)
            |> redirect(to: "/")
            |> halt()
        else
          conn
            |> render("first-login.html", token: token, email: email)
        end
      [{:error, reason}, _] ->
        conn
          |> put_flash(:error, "Could not verify token: #{reason}")
          |> redirect(to: "/auth")
          |> halt()
      [_, _] ->
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
