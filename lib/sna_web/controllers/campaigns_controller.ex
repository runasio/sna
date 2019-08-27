defmodule SnaWeb.CampaignsController do
  use SnaWeb, :controller

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, _params) do
    conn
      |> render("index.html",
        campaigns: Sna.Repo.Campaign.all_from_user_id(current_user(conn).id))
  end
end
