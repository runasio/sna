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

  test "set new action function and ensure it works" do
    pid = self()
    action = fn ({mail, _}) ->
      send(pid, mail)
    end
    assert :ok == Sna.Auth.Mail.set(:action, action)
    assert Sna.Auth.Mail.store("mail@localhost")
    assert_receive "mail@localhost", 2000
  end

  test "set new check function and ensure it works" do
    check = fn ({"mymail@localhost", _}) -> :ok
      (_) -> {:error, :wrong_mail}
    end
    valid_mail = "mymail@localhost"
    unvalid_mail = "random@localhost"
    assert :ok == Sna.Auth.Mail.set(:check, check)
    assert {:error, :unvalid_mail} == Sna.Auth.Mail.store(unvalid_mail)
    
    {:ok, token} = Sna.Auth.Mail.store(valid_mail)
    assert is_bitstring(token) == true
  end

  test "set new timer" do
    assert :ok == Sna.Auth.Mail.set(:timer, 3*100)
  end

end
