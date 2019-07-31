defmodule SnaWeb.ProviderOAuthControllerTest do
  use SnaWeb.ConnCase

  setup do
    Sna.Repo.insert(%Sna.Repo.Provider{
      name:       "github",
      strategy:   "github",
      production: false,
    })

    on_exit(fn ->
      Application.put_env(:sna, :oauth_providers, github: Ueberauth.Strategy.Github)
    end)
  end

  defp example_email do
    "mailbox@example.org"
  end

  defp example_token do
    {:ok, token, _claims} = SnaWeb.Token.generate_bearer(%{"email" => example_email()})
    token
  end

  defp login(conn) do
    conn
      |> post("/auth/email", token: example_token(), login: "login")
      |> recycle()
  end

  test "GET /providers/github/oauth", %{conn: conn} do
    conn = conn
      |> login()
      |> get("/providers/github/oauth")

    assert redirected_to(conn) =~ "github.com"
  end

  test "GET /providers/github/oauth/callback?code=error", %{conn: conn} do
    Application.put_env(:sna, :oauth_providers, github: SnaWeb.UeberauthStrategyGithubMock)

    conn = conn
      |> login()
      |> get("/providers/github/oauth/callback?code=error")

    assert redirected_to(conn) === "/"
    assert get_flash(conn, :error) === "Failed to authenticate."
  end

  test "GET /providers/github/oauth/callback?code=ok", %{conn: conn} do
    import Ecto.Query
    Application.put_env(:sna, :oauth_providers, github: SnaWeb.UeberauthStrategyGithubMock)

    conn = conn
      |> login()
      |> get("/providers/github/oauth/callback?code=ok")

    assert redirected_to(conn) === "/"
    assert get_flash(conn, :info) === "Connected."

    token = Sna.Repo.one(
      from t in Sna.Repo.Token,
      join: p in assoc(t, :provider),
      join: u in assoc(t, :user),
      where: u.email == ^example_email(),
      where: p.name == "github",
      select: t)

    assert token != nil
    assert token.token === "valid-token"
    assert token.token_secret === "valid-secret"
    assert token.retention === 42
  end
end
