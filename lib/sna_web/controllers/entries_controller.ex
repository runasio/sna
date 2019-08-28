defmodule SnaWeb.EntriesController do
  use SnaWeb, :controller

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, _params) do
    conn
      |> render("index.html",
        entries: Sna.Repo.Entry.all_from_user_id(current_user(conn).id))
  end

  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    uid = current_user(conn).id
    entry = id
      |> String.to_integer
      |> Sna.Repo.Entry.get_with_user_id(uid)

    conn
      |> render("show.html", entry: entry)
  end

  @spec destroy(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def destroy(conn, %{"id" => id}) do
    res = id
      |> String.to_integer
      |> Sna.Repo.Entry.get_with_user_id(current_user(conn).id)
      |> Sna.Repo.delete()

    case res do
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
