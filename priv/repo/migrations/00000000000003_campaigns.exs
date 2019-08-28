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

defmodule Sna.Repo.Migrations.Campaigns do
  use Ecto.Migration

  def change do

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS campaigns (
    #     id INTEGER PRIMARY KEY,
    #     name TEST NOT NULL,
    #     user_id INTEGER NOT NULL,
    #     FOREIGN KEY (user_id) REFERENCES users (id)
    # );
    # ----------------------------------------------------------------
    create table(:campaigns) do
      add :name, :string, null: false
      add :user_id, references("users")
      add :entry_id, references("entries")
    end

    create index(:campaigns, [:entry_id], unique: true)

    # ----------------------------------------------------------------
    # CREATE TABLE IF NOT EXISTS campaigns_entries (
    #     id INTEGER PRIMARY KEY,
    #     campaign_id INTEGER NOT NULL,
    #     provider_id INTEGER NOT NULL,
    #     entry_id INTEGER NOT NULL,
    #     FOREIGN KEY (campaign_id) REFERENCES campaigns (id),
    #     FOREIGN KEY (provider_id) REFERENCES providers (id)
    #     FOREIGN KEY (entry_id) REFERENCES entries (id)
    # );
    # ----------------------------------------------------------------
    create table(:scheduled_entries) do
      add :campaign_id, references("campaigns")
      add :provider_id, references("providers")
      add :entry_id, references("entries")
    end

    create index(:scheduled_entries, [:entry_id], unique: true)

  end
end
