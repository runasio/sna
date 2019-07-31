defmodule Sna.Repo.ProviderInfo do

  @moduledoc """
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
    :provider_id     => integer,
    :consumer_key    => String.t,
    :consumer_secret => String.t,
  }

  @primary_key false
  schema "provider_infos" do
    belongs_to :provider, Sna.Repo.Provider, primary_key: true
    field :consumer_key, :string
    field :consumer_secret, :string
  end

  @spec changeset(map, map) :: %Ecto.Changeset{}
  def changeset(model, params \\ %{}) do
    model
      |> cast(params, [:provider_id, :consumer_key, :consumer_secret])
      |> validate_required([:provider_id, :consumer_key, :consumer_secret])
  end
end
