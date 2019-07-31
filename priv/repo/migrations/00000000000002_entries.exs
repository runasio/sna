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

defmodule Sna.Repo.Migrations.Entries do
  use Ecto.Migration

  def change do

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS entries (
    #     id INTEGER PRIMARY KEY,
    #     name TEXT NOT NULL,
    #     content TEXT NOT NULL,
    #     automatic BOOLEAN NOT NULL DEFAULT false
    # );
    # ----------------------------------------------------------------
    create table(:entries) do
      add :name, :string
      add :content, :string, null: false
      add :automatic, :boolean, [null: false, default: false]
    end

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS entries_users (
    #     user_id INTEGER NOT NULL,
    #     provider_id INTEGER NOT NULL,
    #     FOREIGN KEY (user_id) REFERENCES users (id),
    #     FOREIGN KEY (provider_id) REFERENCES providers (id)
    # );
    # ----------------------------------------------------------------
    create table(:entry_user_relations, primary_key: false) do
      add :user_id, references("users", on_delete: :restrict)
      add :entry_id, references("entries", on_delete: :delete_all)
    end

    create index(:entry_user_relations, [:user_id, :entry_id], unique: true)

  end
end
