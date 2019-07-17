defmodule Sna.Repo.UserTest do
  use Sna.DataCase

  alias Sna.Repo.User

  def example_email() do
    "mailbox@example.org"
  end

  def example_login() do
    "example"
  end

  test "email_exists(email) = no" do
    assert User.email_exists(example_email()) === false
  end

  test "insert(); email_exists(email) = yes" do
    {inserted, _} = User.insert(%{
      email: example_email(),
      login: example_login(),
      admin: false
    })
    assert inserted === :ok
    assert User.email_exists(example_email()) === true
  end

  test "insert(email: existing)" do
    User.insert(%{
      email: example_email(),
      login: "other",
      admin: false
    })
    {inserted, changeset} = User.insert(%{
      email: example_email(),
      login: example_login(),
      admin: true
    })
    assert inserted === :error
    [ email: {email_error, _} ] = changeset.errors
    assert email_error === "has already been taken"
  end

  test "insert(login: existing)" do
    User.insert(%{
      email: "other-mailbox@example.org",
      login: example_login(),
      admin: false
    })
    {inserted, changeset} = User.insert(%{
      email: example_email(),
      login: example_login(),
      admin: true
    })
    assert inserted === :error
    [ login: {login_error, _} ] = changeset.errors
    assert login_error === "has already been taken"
    assert User.email_exists(example_email()) === false
  end

  test "insert(email: invalid)" do
    {inserted, changeset} = User.insert(%{
      email: "invalid email",
      login: example_login(),
      admin: true
    })
    assert inserted === :error
    [ email: {email_error, _} ] = changeset.errors
    assert email_error === "has invalid format"
  end
end

