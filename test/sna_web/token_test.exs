defmodule SnaWeb.TokenTest do
  use ExUnit.Case
  doctest SnaWeb

  defp example_email do
    "mailbox@example.org"
  end

  test "token generation and validation" do
    case SnaWeb.Token.generate_bearer(%{"email" => example_email()}) do
      {:ok, token, _} ->
        case SnaWeb.Token.validate_bearer(token) do
          {:ok, %{"email" => email}} ->
            assert email === example_email()
          _ ->
            assert false
        end
      _ ->
        assert false
    end
  end
end

