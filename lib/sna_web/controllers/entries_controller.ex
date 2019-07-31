defmodule SnaWeb.EntriesController do
  use SnaWeb, :controller

  @spec new(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def new(conn, _params) do
    conn
      |> render("form.html",
        entry: %Sna.Repo.Entry{
          id: nil,
          name: "Your entry name",
          content: "Your new entry here"
        },
        submit_method: "POST",
        submit_url: Routes.api_v0_entries_path(conn, :create))
  end

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, _params) do
    conn
      |> render("index.html",
        entries: Sna.Repo.Entry.all_from_user_id(current_user(conn).id))
  end

  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    uid = current_user(conn).id
    conn
      |> render("show.html",
        entry: Sna.Repo.Entry.get_with_user_id(id, uid))
  end

  @spec edit(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def edit(conn, %{"id" => id}) do
    uid = current_user(conn).id
    conn
      |> render("form.html",
        entry: Sna.Repo.Entry.get_with_user_id(id, uid),
        submit_method: "PATCH",
        submit_url: Routes.api_v0_entries_path(conn, :update, id))
  end

  @spec destroy(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def destroy(conn, %{"id" => id}) do
    entry = Sna.Repo.Entry.get_with_user_id(id, current_user(conn).id)
    case Sna.Repo.delete(entry) do
      {:ok, _struct} ->
          conn
            |> put_flash(:info, "Destroyed entry")
      {:error, _changeset} ->
          conn
            |> put_flash(:error, "Could not destroy entry")
    end
      |> redirect(to: Routes.entries_path(conn, :index))
      |> halt()
  end
end
