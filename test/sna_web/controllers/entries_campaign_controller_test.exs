defmodule SnaWeb.EntriesCampaignControllerTest do
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

    {:ok, _} = Sna.Repo.Campaign.changeset(%Sna.Repo.Campaign{
      name:     "Campaign Name",
      entry_id: id2,
    })
      |> Sna.Repo.Campaign.insert_or_update()

    [ conn, uid, id1, id2 ]
  end

  test "GET /entries/:id/campaign/new", %{conn: conn} do
    [conn, _uid, id1, _id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id1}/campaign/new")

    assert html_response(conn, 200) =~ "<form"
  end

  test "GET /entries/:id/campaign, non existing campaign", %{conn: conn} do
    [conn, _uid, id1, _id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id1}/campaign")

    assert redirected_to(conn) === "/entries/#{id1}/campaign/new"
  end

  test "POST /entries/:id/campaign, non existing campaign", %{conn: conn} do
    [conn, _uid, id, _id] = login_and_create_entries(conn)

    conn = conn
      |> post("/entries/#{id}/campaign", campaign: %{name: "campaign name"})

    assert redirected_to(conn) === "/entries/#{id}/campaign"
    assert Sna.Repo.Campaign.exists_by_entry_id?(id)
  end

  test "GET /entries/:id/campaign, existing campaign", %{conn: conn} do
    [conn, _uid, _id1, id2] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id2}/campaign")

    assert html_response(conn, 200) =~ "Campaign Name"
  end

  test "POST /entries/:id/campaign, existing campaign", %{conn: conn} do
    [conn, _uid, _id1, id2] = login_and_create_entries(conn)

    conn = conn
      |> post("/entries/#{id2}/campaign", campaign: %{name: "campaign updated name"})

    assert redirected_to(conn) === "/entries/#{id2}/campaign"
    assert Sna.Repo.Campaign.get_by_entry_id(id2).name === "campaign updated name"
  end

  test "POST /entries/:id/campaign/delete, non existing campaign", %{conn: conn} do
    [conn, _uid, id, _id] = login_and_create_entries(conn)

    conn = conn
      |> post("/entries/#{id}/campaign/delete")

    assert html_response(conn, 404) =~ "Not Found"
  end

  test "POST /entries/:id/campaign/delete, existing campaign", %{conn: conn} do
    [conn, _uid, _id, id] = login_and_create_entries(conn)

    conn = conn
      |> post("/entries/#{id}/campaign/delete")

    assert redirected_to(conn) === "/entries/#{id}"
    assert get_flash(conn, :info) === "Destroyed campaign"
  end

  test "GET /entries/:id/campaign/edit, non existing campaign", %{conn: conn} do
    [conn, _uid, id, _id] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id}/campaign/edit")

    assert html_response(conn, 404) =~ "Not Found"
  end

  test "GET /entries/:id/campaign/edit, existing campaign", %{conn: conn} do
    [conn, _uid, _id, id] = login_and_create_entries(conn)

    conn = conn
      |> get("/entries/#{id}/campaign/edit")

    assert html_response(conn, 200) =~ "<form"
  end
end

