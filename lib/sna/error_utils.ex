defmodule Sna.ErrorUtils do

  @doc """
  changeset_errors takes a changeset and return structured errors, a list of
  error strings organized in a map keyed by field name.
  """

  @spec changeset_errors(Ecto.Changeset.t) :: %{required(atom) => [String.t]}
  def changeset_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

end
