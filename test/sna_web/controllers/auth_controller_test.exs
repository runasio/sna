defmodule SnaWeb.AuthControllerTest do
  use SnaWeb.ConnCase

  defp example_email do
    "mailbox@example.org"
  end

  defp example_token do
    case SnaWeb.Token.generate_bearer(%{"email" => example_email()}) do
      {:ok, token, _claims} ->
        token

      {:error, reason} ->
        raise Joken.Error, [:bad_generate_and_sign, reason: reason]
    end
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "<a href=\"/auth\">Authenticate</a>"
  end

  test "GET /auth", %{conn: conn} do
    conn = get(conn, "/auth")
    assert html_response(conn, 200) =~ "<form method=\"post\" action=\"/auth/email\""
    assert html_response(conn, 200) =~ "<input type=\"text\" name=\"email\""
  end

  test "POST /auth/email?email", %{conn: conn} do
    conn = post(conn, "/auth/email", email: example_email())
    assert html_response(conn, 200) =~ "<form method=\"post\" action=\"/auth/email\""
    assert html_response(conn, 200) =~ "<input type=\"text\" name=\"token\""
  end

  test "POST /auth/email?token=valid", %{conn: conn} do
    token = example_token()
    conn = conn
      |> post("/auth/email", token: token)

    assert redirected_to(conn) === "/"
    assert get_session(conn, "auth_token") === token

    conn = conn
      |> recycle()
      |> get("/")

    assert html_response(conn, 200) =~ "Authenticated as #{example_email()}"
    assert html_response(conn, 200) =~ "<a href=\"/auth/logout\">log-out</a>"

    conn = conn
      |> recycle()
      |> get("/auth/logout")

    assert redirected_to(conn) === "/"
    assert get_session(conn, "auth_token") === nil

    conn = conn
      |> recycle()
      |> get("/")

    assert html_response(conn, 200) =~ "<a href=\"/auth\">Authenticate</a>"
  end

  test "POST /auth/email?token=invalid", %{conn: conn} do
    conn = conn
      |> post("/auth/email", token: "invalid.jwt.token")

    assert redirected_to(conn) === "/auth"
    assert get_flash(conn, :error) =~ "Could not verify token"
  end

  test "POST /auth/email?token=empty", %{conn: conn} do
    example_token = Joken.generate_and_sign!(SnaWeb.Token.bearer_config, nil, SnaWeb.Token.app_signer)
    conn = conn
      |> post("/auth/email", token: example_token)

    assert redirected_to(conn) === "/auth"
    assert get_flash(conn, :error) =~ "No valid claims"
  end
end
