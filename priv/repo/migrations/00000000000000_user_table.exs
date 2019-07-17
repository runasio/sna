# --------------------------------------------------------------------
# Ecto.Migration Database File for SNA
#
# You can deploy this migration file by executing this code. You need
# superadmin access (right to create/drop database) for the first
# command.
#
#   #!/bin/sh
#   # drop the content of the database
#   mix ecto.drop
#
#   # create the database
#   mix ecto.create
#
#   # create the schema
#   mix ecto.migrate
#
# --------------------------------------------------------------------

defmodule Sna.Repo.Migrations.UserTable do
  use Ecto.Migration

  def change do

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS users (
    #     id INTEGER PRIMARY KEY,
    #     login STRING NOT NULL UNIQUE,
    #     email STRING NOT NULL UNIQUE,
    #     admin BOOLEAN NOT NULL DEFAULT false
    # );
    #
    # RULES:
    #   A login must be unique
    #   An email must be unique
    #   A {login, email} couple is necessary unique too
    # ----------------------------------------------------------------
    create table(:users) do
      add :login, :string, [size: 64, null: false]
      add :email, :string, [size: 256, null: false]
      add :password, :string
      add :admin, :boolean, [default: false, null: false]
    end

    create index(:users, :login, unique: true)
    create index(:users, :email, unique: true)
  end
end
