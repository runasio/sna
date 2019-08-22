defmodule SnaWeb.PageController do
  use SnaWeb, :controller

  def index(conn, _params) do
    uid = current_user(conn).id
    authenticated = case current_user(conn) do
      %{email: email} -> true
      _ -> false
    end

    conn
      |> render("index.html",
        entries: Sna.Repo.Entry.all_from_user_id(uid, with_campaigns: false),
        campaigns: Sna.Repo.Campaign.all_from_user_id(uid),
        authenticated: authenticated)
  end
end
