defmodule SnaWeb.Mail do
  import Bamboo.Email

  @doc """

  token_validation/2 is used to generate a mail datastructure. Notes
  that you need to configure Sna.Mail env in config.exs.

      iex> token_validation("root@localhost", "my_token")
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
  @spec token_validation(term(), bitstring(), bitstring()) :: Bamboo.Email.t()
  def token_validation(conn, to_mail, token) do
    from_mail = Application.get_env(:sna, SnaWeb.Mail)
    |> Keyword.get(:from, "")
    
    subject = Application.get_env(:sna, SnaWeb.Mail)
    |> Keyword.get(:subject, "SNA Mail Validation")

    link = SnaWeb.Mail.link(conn, token)
    
    new_email(from: from_mail)
    |> to(to_mail)
    |> subject(subject)
    |> text_body("Please confirm your email by clicking on this link: #{link}.")
    |> deliver_now()
  end

  @doc """
  
  deliver_now/1 is a wrapper around Sna.Mail.deliver_now/1 and permit
  to send an email.
  
  """
  @spec deliver_now(Bamboo.Email.t()) :: Bamboo.Email.t()
  def deliver_now(mail) do
    mail |> Sna.Mailer.deliver_now
  end

  def link(conn, token) do
    url = SnaWeb.Router.Helpers.url(conn)
    url <> SnaWeb.Router.Helpers.auth_path(conn, :email, %{ "token" => token})
  end
end
