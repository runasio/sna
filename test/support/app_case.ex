defmodule SnaWeb.AppCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      def login(conn, email, login) do
        {:ok, token, _claims} = SnaWeb.Token.generate_bearer(%{"email" => email})
        conn = conn
          |> post("/auth/email", token: token, login: login)
        assert Sna.Repo.User.email_exists(email)
        assert get_session(conn, "auth_token") === token
        recycle(conn)
      end

      def current_user(conn) do
        conn
          |> recycle
          |> get("/")
          |> SnaWeb.Auth.current_user
      end
    end
  end
end
