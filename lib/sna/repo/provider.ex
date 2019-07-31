defmodule Sna.Repo.Provider do

  @moduledoc """

  Sna.Repo.Provider is the Ecto Abstration of the `providers` table present
  in database.

  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
    optional(:id)  => integer,
    :name          => String.t,
    :strategy      => String.t,
    :production    => boolean,
    :provider_info => Sna.Repo.ProviderInfo.t
  }

  schema "providers" do
    field :name,       :string
    field :strategy,   :string
    field :production, :boolean
    has_one :provider_info, Sna.Repo.ProviderInfo
  end

  @spec changeset(map, map) :: %Ecto.Changeset{}
  def changeset(model, params \\ %{}) do
    model
      |> cast(params, [:name, :strategy, :production])
      |> unique_constraint(:name)
  end

  @spec get(String.t) :: __MODULE__.t
  def get(name) do
    import Ecto.Query
    [ res ] = Sna.Repo.all(
      from p in __MODULE__,
      left_join: i in assoc(p, :provider_info),
      where: p.name == ^name,
      preload: [provider_info: i])
    res
  end
end
