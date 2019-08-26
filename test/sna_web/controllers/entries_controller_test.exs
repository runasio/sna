defmodule SnaWeb.EntriesControllerTest do
  use SnaWeb.ConnCase
  use SnaWeb.AppCase
  use SnaWeb.ApiCase

  defp login_and_create_entries(conn) do
    conn = conn
      |> login("mailbox@example.org", "login")

    %{id: uid} = current_user(conn)

    {:ok, %{id: id1}} = Sna.Repo.Entry.record(%{
      name: "Entry name 1",
      content: "Entry content 1"
    })
      |> Sna.Repo.Entry.insert_with_user_id(uid)

    {:ok, %{id: id2}} = Sna.Repo.Entry.record(%{
      name: "Entry name 2",
      content: "Entry content 2"
    })
      |> Sna.Repo.Entry.insert_with_user_id(uid)

    [ conn, uid, id1, id2 ]
  end

  test "GET /entries", %{conn: conn} do
    [conn, _uid, _id1, _id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries")

    assert html_response(conn, 200) =~ "Entry name 1"
    assert html_response(conn, 200) =~ "Entry content 1"
    assert html_response(conn, 200) =~ "Entry name 2"
    assert html_response(conn, 200) =~ "Entry content 2"
  end

  test "GET /entries/:id", %{conn: conn} do
    [conn, _uid, id1, id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id1}")

    assert html_response(conn, 200) =~ "Entry name 1"
    assert html_response(conn, 200) =~ "Entry content 1"

    conn = conn
      |> get("/entries/#{id2}")

    assert html_response(conn, 200) =~ "Entry name 2"
    assert html_response(conn, 200) =~ "Entry content 2"
  end

  test "GET /entries/:id/edit", %{conn: conn} do
    [conn, _uid, id1, id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id1}/edit")

    assert html_response(conn, 200) =~ "<div id=\"editor\""
    assert html_response(conn, 200) =~ "<input name=\"name\" type=\"text\" value=\"Entry name 1\""
    assert html_response(conn, 200) =~ "Entry content 1"

    conn = conn
      |> get("/entries/#{id2}/edit")

    assert html_response(conn, 200) =~ "<div id=\"editor\""
    assert html_response(conn, 200) =~ "<input name=\"name\" type=\"text\" value=\"Entry name 2\""
    assert html_response(conn, 200) =~ "Entry content 2"
  end

  test "GET /entries/new", %{conn: conn} do
    [conn, _uid, _id1, _id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/new")

    assert html_response(conn, 200) =~ "<div id=\"editor\""
    assert html_response(conn, 200) =~ "<input name=\"name\" type=\"text\" value=\"Your entry name\""
  end

  test "POST /entries/:id/delete", %{conn: conn} do
    [conn, _uid, id1, id2] = login_and_create_entries(conn)

    assert Sna.Repo.Entry.get(id1) != nil

    conn = conn
      |> post("/entries/#{id1}/delete")

    assert redirected_to(conn) === "/entries"
    assert get_flash(conn, :info) === "Destroyed entry"
    assert Sna.Repo.Entry.get(id1) == nil
    assert Sna.Repo.Entry.get(id2) != nil
  end
end

