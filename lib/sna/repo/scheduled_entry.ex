defmodule Sna.Repo.ScheduledEntry do

  @moduledoc """

  Sna.Repo.Provider is the Ecto Abstration of the `scheduled_entries` table
  present in database.

  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    id:       nil | integer,
    campaign: Sna.Repo.Campaign.t,
    provider: Sna.Repo.Provider.t,
    entry:    nil | Sna.Repo.Entry.t
  }

  @type changeset :: Ectp.Changeset.t(t)

  schema "scheduled_entries" do
    belongs_to :campaign, Sna.Repo.Campaign
    belongs_to :provider, Sna.Repo.Provider
    belongs_to :entry,    Sna.Repo.Entry
  end

  @spec changeset(t | changeset | Ecto.Schema.t, map) :: changeset
  def changeset(model, params) do
    model
      |> cast(params, [:campaign_id, :provider_id, :entry_id])
      |> cast_assoc(:campaign, with: &Sna.Repo.Campaign.changeset/1)
      |> cast_assoc(:provider, with: &Sna.Repo.Provider.changeset/1)
      |> cast_assoc(:entry,    with: &Sna.Repo.Entry.changeset/1)
  end

  @spec changeset(t | changeset | Ecto.Schema.t | map) :: changeset
  def changeset(%__MODULE__{} = model), do: changeset(model, %{})
  def changeset(%{} = params), do: changeset(%__MODULE__{}, params)

  @spec get_by_campaign_and_provider_ids(integer, integer) :: nil | __MODULE__.t
  def get_by_campaign_and_provider_ids(campaign_id, provider_id) do
    import Ecto.Query
    Sna.Repo.one(
      from e in __MODULE__,
      where: e.campaign_id == ^campaign_id,
      where: e.provider_id == ^provider_id)
  end
end
