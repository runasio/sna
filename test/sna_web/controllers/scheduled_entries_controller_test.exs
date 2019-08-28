defmodule SnaWeb.ScheduledEntriesControllerTest do
  use SnaWeb.ConnCase
  use SnaWeb.AppCase
  use SnaWeb.ApiCase

  defp login_and_init(conn) do
    conn = conn
      |> login("mailbox@example.org", "login")

    %{id: uid} = current_user(conn)

    {:ok, %{id: entry_id}} = Sna.Repo.Entry.record(%{
      name: "Entry name 1",
      content: "Entry content 1"
    })
      |> Sna.Repo.Entry.insert_with_user_id(uid)

    {:ok, %{id: campaign_id}} = Sna.Repo.Campaign.changeset(%Sna.Repo.Campaign{
      name:     "Campaign Name",
      entry_id: entry_id,
    })
      |> Sna.Repo.Campaign.insert_or_update()

    {:ok, %{id: provider_id}} = Sna.Repo.insert(%Sna.Repo.Provider{
      name:       "github",
      strategy:   "github",
      production: false,
    })

    %{
      conn: conn,
      entry_id: entry_id,
      campaign_id: campaign_id,
      provider_id: provider_id,
    }
  end

  test "POST /scheduled_entries", %{conn: conn} do
    %{ conn: conn, entry_id: eid, campaign_id: cid, provider_id: pid } = login_and_init(conn)

    conn = conn
      |> post("/scheduled_entries",
        scheduled_entry: %{provider_id: pid, campaign_id: cid})

    assert Sna.Repo.ScheduledEntry.get_by_campaign_and_provider_ids(cid, pid) != nil
    assert redirected_to(conn) === "/entries/#{eid}/campaign"
  end
end

