defmodule Sna.Repo.User do

  @moduledoc """

  Sna.Repo.User is the Ecto Abstration of the `users` table present
  in database.

  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
    optional(:id) => integer,
    :login        => String.t,
    :email        => String.t,
    :admin        => boolean,
  }

  schema "users" do
    field :login, :string
    field :email, :string
    field :admin, :boolean
  end

  def changeset(model, params \\ %{}) do
    model
      |> cast(params, [:email, :login])
      |> validate_required([:email, :login])

      # Validates login
      |> validate_length(:login, min: 1, max: 64)
      |> validate_format(:login, ~r/\w+/)
      |> unique_constraint(:login)

      # Validate email
      |> validate_length(:email, min: 6, max: 256)
      |> validate_format(:email, ~r/.+@.+/)
      |> unique_constraint(:email)
  end

  @spec email_exists(String.t) :: boolean
  def email_exists(email) do
    import Ecto.Query
    case Sna.Repo.all(
      from u in __MODULE__,
      where: u.email == ^email,
      select: count(u.email))
    do
      [0] ->
        false
      [1] ->
        true
    end
  end

  @spec get_by_email(String.t) :: __MODULE__.t
  def get_by_email(email) do
    import Ecto.Query
    [ res ] = Sna.Repo.all(
      from u in __MODULE__,
      where: u.email == ^email)
    res
  end

  @spec insert(__MODULE__.t) :: {:ok, __MODULE__.t} | {:error, Ecto.Changeset.t()}
  def insert(data) do
    changeset(%__MODULE__{}, data)
      |> Sna.Repo.insert
  end
end
