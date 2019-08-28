defmodule Sna.Repo.Campaign do

  @moduledoc """

  Sna.Repo.Provider is the Ecto Abstration of the `campaigns` table present
  in database.

  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    id:    nil | integer,
    name:  String.t,
    user:  Sna.Repo.User.t,
    entry: Sna.Repo.Entry.t,
  }

  schema "campaigns" do
    field :name, :string

    belongs_to :user,              Sna.Repo.User
    belongs_to :entry,             Sna.Repo.Entry
    has_many   :scheduled_entries, Sna.Repo.ScheduledEntry
  end

  @spec changeset(map, map) :: %Ecto.Changeset{}
  def changeset(model, params \\ %{}) do
    model
      |> cast(params, [:name])
      |> validate_required([:name])
      |> validate_length(:name, min: 1)
      |> unique_constraint(:entry_id)
  end

  @spec get_by_entry_id(integer) :: __MODULE__.t | nil
  def get_by_entry_id(entry_id) do
    import Ecto.Query
    Sna.Repo.one(
      from c in __MODULE__,
      join: e in assoc(c, :entry),
      preload: [entry: e],
      where: c.entry_id == ^entry_id)
  end

  @spec all_from_user_id(integer) :: [__MODULE__.t]
  def all_from_user_id(uid) do
    import Ecto.Query
    Sna.Repo.all(
      from c in __MODULE__,
      join: e in assoc(c, :entry),
      join: r in assoc(e, :entry_user_relations),
      preload: [entry: e],
      where: r.user_id == ^uid
    )
  end

  @spec exists_by_entry_id?(integer) :: boolean
  def exists_by_entry_id?(entry_id) do
    import Ecto.Query
    Sna.Repo.exists?(
      from c in __MODULE__,
      where: c.entry_id == ^entry_id)
  end

  #spec insert_or_update(Ecto::Changeset.t) :: (({:ok, __MODULE__.t}) | ({:error, Ecto.Changeset.t}))
  def insert_or_update(changeset) do
    Sna.Repo.insert_or_update(changeset)
  end
end
