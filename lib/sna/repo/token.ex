defmodule Sna.Repo.Token do

  @moduledoc """
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
    optional(:id) => integer,
    :token        => String.t,
    :token_secret => String.t,
    :creation     => integer,
    :retention    => integer,
  }

  @doc """
  """
  @primary_key false
  schema "tokens" do
    belongs_to :user, Sna.Repo.User, primary_key: true
    belongs_to :provider, Sna.Repo.Provider, primary_key: true
    field :token, :string
    field :token_secret, :string
    field :creation, :integer
    field :retention, :integer
  end

  @doc """
  """
  def changeset(model, params \\ %{}) do
    model
      |> cast(params, [:user_id, :provider_id, :token, :token_secret, :creation, :retention])
      # TODO: Validate user
      # TODO: Validate provider
      # TODO: Validate token
      # TODO: Validate secret
      # TODO: Validate creation
      # TODO: Validate retention
  end

end
