defmodule SnaWeb.ScheduledEntriesController do
  use SnaWeb, :controller

  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn, %{ "scheduled_entry" => params }) do
    campaign = Sna.Repo.get(Sna.Repo.Campaign, params["campaign_id"])
    changeset = Sna.Repo.ScheduledEntry.changeset(params)

    case Sna.Repo.insert(changeset) do
      {:ok, _campaign} ->
        conn
      {:error, _changeset} ->
        conn
          |> put_flash(:error, "Could not create scheduled entry")
    end
      |> redirect(to: Routes.entries_campaign_path(conn, :show, campaign.entry_id))
  end
end
