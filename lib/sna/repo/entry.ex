defmodule Sna.Repo.Entry do

  @moduledoc """

  Sna.Repo.Provider is the Ecto Abstration of the `entries` table present
  in database.

  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
    optional(:id) => integer,
    :name         => String.t,
    :content      => String.t,
    :automatic    => boolean,
  }

  schema "entries" do
    field :name,      :string
    field :content,   :string
    field :automatic, :boolean

    many_to_many :users,                Sna.Repo.User, join_through: "entry_user_relations"
    has_many     :entry_user_relations, Sna.Repo.EntryUserRelation
    has_one      :campaign,             Sna.Repo.Campaign
  end

  @spec record(%{}) :: %Ecto.Changeset{}
  def record(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @spec changeset(map, map) :: %Ecto.Changeset{}
  def changeset(model, params \\ %{}) do
    model
      |> cast(params, [:name, :content, :automatic])
      |> validate_required([:name, :content])
      |> validate_length(:name, min: 1)
      |> validate_length(:content, min: 1)
  end

  @doc """
  get fetches an entry from the database given its id
  """

  @spec get(integer) :: nil | __MODULE__.t
  def get(id) do
    import Ecto.Query
    Sna.Repo.one(from e in __MODULE__, where: e.id == ^id, preload: [:users])
  end

  @doc """
  insert_with_user_id inserts an entry changeset to the database, associating
  the created entry with the user id provided
  """

  @spec insert_with_user_id(%Ecto.Changeset{}, integer) :: {:ok, __MODULE__.t} | {:error, Ecto.Changeset.t}
  def insert_with_user_id(entry, uid) do
    res = Ecto.Multi.new()
      |>  Ecto.Multi.insert(:entry, entry)
      |>  Ecto.Multi.insert(:entry_user_relation, fn %{entry: entry} ->
            %Sna.Repo.EntryUserRelation{
              entry_id: entry.id,
              user_id:  uid,
            }
          end)
      |>  Sna.Repo.transaction()
    case res do
      {:ok, record} ->
        {:ok, record[:entry]}
      {:error, _operation, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  all_from_user_id fetches a list of entries from the database associated with
  the provided user id
  """

  @spec all_from_user_id(integer) :: [%Sna.Repo.Entry{}]
  def all_from_user_id(uid) do
    import Ecto.Query
    Sna.Repo.all(
      from e in Sna.Repo.Entry,
      join: r in assoc(e, :entry_user_relations),
      where: r.user_id == ^uid
    )
  end

  @doc """
  get_with_user_id fetches an entry by its id, but only of the entry belongs to
  the user whose id is provided as second argument
  """

  @spec get_with_user_id(integer, integer) :: %Sna.Repo.Entry{} | nil
  def get_with_user_id(id, uid) do
    import Ecto.Query
    Sna.Repo.one(
      from e in Sna.Repo.Entry,
      join: r in assoc(e, :entry_user_relations),
      where: r.user_id == ^uid,
      where: e.id == ^id
    )
  end
end
