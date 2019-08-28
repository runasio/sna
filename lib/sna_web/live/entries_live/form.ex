defmodule SnaWeb.EntriesLive.Form do
  use SnaWeb, :live
  require Logger

  def page_title(_assigns), do: "New Entry"
  def view_module,          do: SnaWeb.EntriesView
  def view_template,        do: "_form.html"
  def render(assigns),      do: render(view_module(), view_template(), assigns)

  def mount(%{auth: auth, path_params: %{"id" => entry_id}}, socket) do
    changeset = entry_id
      |> String.to_integer
      |> Sna.Repo.Entry.get_with_user_id(auth.id)
      |> Sna.Repo.Entry.changeset()

    {:ok, assign(socket, %{
      uid:   auth.id,
      entry: changeset
    })}
  end

  def mount(%{auth: auth}, socket) do
    {:ok, assign(socket, %{
      uid:   auth.id,
      entry: Sna.Repo.Entry.changeset(%Sna.Repo.Entry{
        name: "Your entry name",
        content: "Your new entry here"
      })
    })}
  end


  def handle_event("validate", %{"entry" => params}, socket) do
    entry = socket.assigns.entry
      |> Sna.Repo.Entry.changeset(params)

    {:noreply, assign(socket, entry: entry)}
  end

  def handle_event("save", %{"entry" => params}, socket) do
    res = socket.assigns.entry
      |> Sna.Repo.Entry.changeset(params)
      |> insert_or_update(socket.assigns.uid)

    case res do
      {:ok, entry} ->
        socket = socket
          |> redirect(to: Routes.entries_path(socket, :show, entry.id))
        {:stop, socket}
      {:error, entry} ->
        {:noreply, assign(socket, entry: entry)}
    end
  end

  defp insert_or_update(%{ data: %{ id: nil } } = changeset, uid) do
    Logger.warn("changeset = #{inspect(changeset)}")
    Logger.warn("changeset.data = #{inspect(changeset.data)}")
    Sna.Repo.Entry.insert_with_user_id(changeset, uid)
  end

  defp insert_or_update(%{ data: %{ id: _entry_id } } = changeset, _uid) do
    Logger.warn("changeset = #{inspect(changeset)}")
    Logger.warn("changeset.data = #{inspect(changeset.data)}")
    Sna.Repo.update(changeset)
  end
end

