defmodule Sna.Auth.MailTest do
  use ExUnit
  test "insert a new valid mail" do
    assert Sna.Auth.Mail.insert("root@localhost") == :ok
  end

  test "insert an unvalid mail" do
    assert Sna.Auth.Mail.insert("dum") == {:error, :invalid}
  end

  test "check if a mail is present" do
    Sna.Auth.Mail.insert_mail("root@localhost") 
    Sna.Auth.Mail.check_mail("root@localhost") == :true
    Sna.Auth.Mail.check_mail("dum@localhost") == :false
  end

  test "return the token based on the mail" do
    Sna.Auth.Mail.insert_mail("root@localhost")
    Sna.Auth.Mail.get_token("root@localhost") =~ {:ok, :mytoken}
  end
end
