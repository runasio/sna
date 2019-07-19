defmodule SnaWeb.MailTest do
  use ExUnit.Case
  use Plug.Test
  
  test "generate a link" do
    link = "http://www.example.com/auth/email?token=\"test\""
    conn(:get, "/auth/email", %{ "token" => "test" })
  end
  
  test "ensure email is delivered" do
    email = conn(:get, "/auth/email", %{ "email" => "test@localhost", "token" => "test" })
    |> SnaWeb.Mail.token_validation("test@localhost", "test")
    assert email.to == "test@localhost"
    assert email.subject == "SNA Mail Validation"
    assert email.text_body =~ "Please"
  end
end
