defmodule Sna.Repo.ScheduledEntry do

  @moduledoc """

  Sna.Repo.Provider is the Ecto Abstration of the `scheduled_entries` table
  present in database.

  """

  use Ecto.Schema

  @type t :: %{
    optional(:id)    => integer,
    :campaign        => Sna.Repo.Campaign.t,
    :provider        => Sna.Repo.Provider.t,
    optional(:entry) => Sna.Repo.Entry.t
  }

  schema "scheduled_entries" do
    belongs_to :campaign, Sna.Repo.Campaign
    belongs_to :provider, Sna.Repo.Provider
    belongs_to :entry,    Sna.Repo.Entry
  end

end
