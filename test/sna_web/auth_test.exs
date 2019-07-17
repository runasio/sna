defmodule SnaWeb.AuthTest do
  use ExUnit.Case
  use SnaWeb.ConnCase
  doctest SnaWeb

  defp example_email do
    "mailbox@example.org"
  end

  defp example_request do
    build_conn("GET", "/")
      |> Plug.Test.init_test_session(foo: "bar")
      |> fetch_flash()
  end

  defp example_token do
    case SnaWeb.Token.generate_bearer(%{"email" => example_email()}) do
      {:ok, token, _claims} ->
        token

      {:error, reason} ->
        raise Joken.Error, [:bad_generate_and_sign, reason: reason]
    end
  end

  test "checks valid session token returns current_user" do
    conn = example_request()
      |> put_session("auth_token", example_token())

    conn = SnaWeb.Auth.check_auth(conn, nil)

    assert SnaWeb.Auth.current_user(conn) == %{email: example_email()}
  end

  test "checks invalid session token returns nil current_user" do
    conn = example_request()
      |> put_session("auth_token", "invalid.jwt.token")

    conn = SnaWeb.Auth.check_auth(conn, nil)

    assert SnaWeb.Auth.current_user(conn) == nil
  end

  test "checks no claim token returns nil current_user" do
    example_token = Joken.generate_and_sign!(SnaWeb.Token.bearer_config, nil, SnaWeb.Token.app_signer)
    conn = example_request()
      |> put_session("auth_token", example_token)

    conn = SnaWeb.Auth.check_auth(conn, nil)

    assert SnaWeb.Auth.current_user(conn) == nil
  end

end

