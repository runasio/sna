defmodule SnaWeb.Mail do
  import Bamboo.Email
  import Bamboo.Phoenix

  @doc """

  token_validation/3 is used to generate a mail datastructure.

      iex> token_validation("root@localhost", "root@localhost", "my_token")
      %Bamboo.Email{
        assigns: %{},
        attachments: [],
        bcc: [],
        cc: [],
        from: {nil, "root@localhost"},
        headers: %{},
        html_body: nil,
        private: %{},
        subject: "SNA Token Validation",
        text_body: "Please confirm your email by clicking on this link: my_token.",
        to: [nil: "root@localhost"]
      }

  """
  @spec token_validation(bitstring(), bitstring(), bitstring()) :: %Bamboo.Email.t()
  def token_validation(from_mail, to_mail, token) do
    new_email(from: from_mail)
    |> to(to_mail)
    |> subject("SNA Token Validation")
    |> text_body("Please confirm your email by clicking on this link: #{token}.")
  end

  @doc """

  deliver_now/1 is a wrapper around Sna.Mail.deliver_now/1 and permit
  to send an email.

  """
  @spec deliver_now(Bamboo.Email.t()) :: %Bamboo.Email.t()
  def deliver_now(mail) do
    mail |> Sna.Mailer.deliver_now
  end
end
