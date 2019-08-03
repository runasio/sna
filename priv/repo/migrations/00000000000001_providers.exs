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

defmodule Sna.Repo.Migrations.Providers do
  use Ecto.Migration

  def change do

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS providers (
    #     id INTEGER PRIMARY KEY,
    #     name STRING NOT NULL UNIQUE,
    #     strategy STRING NOT NULL,
    #     production BOOLEAN DEFAULT false NOT NULL
    # );
    #
    # RULES:
    #  A provider must have an unique name
    # ----------------------------------------------------------------
    create table(:providers) do
      add :name, :string, [null: false]
      add :strategy, :string, [null: false]
      add :production, :boolean, [default: false, null: false]
    end

    create index(:providers, :name, unique: true)

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS provider_infos (
    #     provider_id INTEGER PRIMARY KEY,
    #     consumer_key STRING NOT NULL,
    #     consumer_secret STRING NOT NULL,
    #     FOREIGN KEY (id) REFERENCES providers (id)
    # );
    #
    # RULES:
    #   {provider_id, consumer_key, consumer_secret} must be unique
    # ----------------------------------------------------------------
    create table(:provider_infos, primary_key: false) do
      add :provider_id, references("providers"), primary_key: true
      add :consumer_key, :string, [null: false]
      add :consumer_secret, :string, [null: false]
    end

    create index(:provider_infos,
      [:provider_id, :consumer_key, :consumer_secret],
      unique: true)

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS tokens (
    #     provider_id INTEGER NOT NULL,
    #     user_id INTEGER NOT NULL,
    #     token STRING NOT NULL,
    #     token_secret STRING NOT NULL,
    #     creation INTEGER NOT NULL,
    #     retention INTEGER,
    #     FOREIGN KEY (provider_id) REFERENCES providers (id),
    #     FOREIGN KEY (user_id) REFERENCES users (id)
    # );
    # ----------------------------------------------------------------
    create table(:tokens, primary_key: false) do
      add :user_id, references("users")
      add :provider_id, references("providers")
      add :token, :string
      add :token_secret, :string
      add :creation, :integer
      add :retention, :integer
    end

    create index(:tokens, [:user_id, :provider_id], unique: true)
  end
end
