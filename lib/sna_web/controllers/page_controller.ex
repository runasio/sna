defmodule SnaWeb.PageController do
  use SnaWeb, :controller

  plug :check_auth

  @spec check_auth(Plug.Conn.t, any) :: Plug.Conn.t
  def check_auth(conn, _) do
    uid = case current_user(conn) do
      %{id: uid} -> uid
      _          -> nil
    end

    conn
      |> put_arg(:uid, uid)
  end

  @spec index(Plug.Conn.t, map, map) :: Plug.Conn.t
  def index(conn, _params, %{uid: nil}) do
    conn
      |> render("index.html",
        authenticated: false)
  end

  def index(conn, _params, %{uid: uid}) do
    user = Sna.Repo.get(Sna.Repo.User, uid)
      |> Sna.Repo.preload(tokens: [:provider])

    tokens = user.tokens
      |> List.foldl(Map.new, fn (x, m) ->
        Map.put(m, x.provider.name, Map.get(m, x.provider.name, []) ++ [x])
      end)

    conn
      |> render("index.html",
        entries: Sna.Repo.Entry.all_from_user_id(uid, with_campaigns: false),
        campaigns: Sna.Repo.Campaign.all_from_user_id(uid),
        user: user,
        tokens: tokens,
        authenticated: true)
  end
end
