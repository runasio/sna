defmodule SnaWeb.Token do
  use Joken.Config

  @spec app_signer :: Joken.Signer.t()
  def app_signer do
    Joken.Signer.create("HS256", Application.get_env(:sna, SnaWeb.Endpoint)[:secret_key_base])
  end

  @spec bearer_config :: Joken.token_config()
  def bearer_config do
    default_claims(iss: "SnaWeb", aud: "SnaWeb")
  end

  @doc """
  Generates a bearer token given the provided e-mail
  """
  @spec generate_bearer(%{binary => term}) :: {:ok, Joken.bearer_token, Joken.claims} | {:error, Joken.error_reason}
  def generate_bearer(%{"email" => email}) do
    config = bearer_config()
      |> add_claim("email", fn -> email end)
    Joken.generate_and_sign(config, %{}, app_signer())
  end

  @doc """
  Checks a bearer token and returns a set of claims. If validation succeeds, the
  token does not always represents a signed-in user. Check the returned claims
  (email) to be sure what the user is.
  """
  @spec validate_bearer(Joken.bearer_token) :: {:ok, Joken.claims} | {:error, Joken.error_reason}
  def validate_bearer(token) do
    Joken.verify_and_validate(bearer_config(), token, app_signer())
  end

  @spec error_message(binary, Joken.error_reason) :: binary
  def error_message(prefix, reason) do
    case reason do
      [{:message, msg} | _] -> "#{prefix}: #{msg}"
      _ -> prefix
    end
  end
end
