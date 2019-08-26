defmodule Sna.Repo.EntryUserRelation do

  @moduledoc """

  Sna.Repo.Provider is the Ecto Abstration of the `entry_user_relations` table
  present in database.

  """

  use Ecto.Schema

  @type t :: %{
    :entry_id => integer,
    :user_id  => integer,
  }

  @primary_key false
  schema "entry_user_relations" do
    belongs_to :entry, Sna.Repo.Entry, primary_key: true
    belongs_to :user,  Sna.Repo.User,  primary_key: true
  end
end
