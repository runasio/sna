defmodule Sna.Auth.MailTest do
  use ExUnit

  test "insert a new mail to validate and return a token" do
    {:ok, token} = Sna.Auth.Mail.store("mymail@localhost")
  end
  
end
