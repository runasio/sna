defmodule SnaWeb.MailTest do
  use ExUnit.Case
  use Plug.Test
  
  test "generate a link" do
    SnaWeb.Mail.link()
  end
  
  test "create an email text template" do
  end

  test "create an email HTML template" do
  end

  
end
