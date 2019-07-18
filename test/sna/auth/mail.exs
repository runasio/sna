defmodule Sna.Auth.MailTest do
  use ExUnit.Case
  doctest Sna

  test "ensure Sna.Auth.MailTest is started" do
    pid = :erlang.whereis(Sna.Auth.Mail)
    assert is_pid(pid) == true 
  end
  
  test "store and unvalidate a mail" do
    mail = "mymail@localhost"
    {:ok, token} = Sna.Auth.Mail.store(mail)
    assert is_bitstring(token) == true
    assert :ok == Sna.Auth.Mail.unvalidate(token)
    assert {:error, :unvalid_token} == Sna.Auth.Mail.validate(token)
  end

  test "store and validate a mail" do
    mail = "mymail@localhost"
    {:ok, token} = Sna.Auth.Mail.store(mail)
    assert {:ok, mail} == Sna.Auth.Mail.validate(token)
  end
  
end
