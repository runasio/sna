defmodule SnaWeb.EntriesCampaignController do
  use SnaWeb, :controller

  plug :params
  plug :campaign_exists when action in [:destroy, :edit]
  plug :dummy_campaign when action in [:new]

  @spec params(Plug.Conn.t, any) :: Plug.Conn.t
  def params(%{params: %{"id" => entry_id}} = conn, _) do
    entry_id = entry_id |> String.to_integer
    uid = current_user(conn).id
    conn = conn
      |> put_view(SnaWeb.CampaignsView)
      |> put_arg(:uid, uid)

    case Sna.Repo.Entry.get_with_user_id(entry_id, uid) do
      nil ->
        conn
          |> put_view(SnaWeb.ErrorView)
          |> put_status(404)
          |> render(:"404")
          |> halt
      entry ->
        entry = Sna.Repo.preload entry, :campaign
        conn
          |> put_arg(:entry, entry)
          |> put_arg(:campaign, entry.campaign)
    end
  end

  @spec campaign_exists(Plug.Conn.t, any) :: Plug.Conn.t
  def campaign_exists(%{assigns: %{controller_args: %{campaign: campaign}}} = conn, _) do
    case campaign do
      nil ->
        conn
          |> put_view(SnaWeb.ErrorView)
          |> put_status(404)
          |> render(:"404")
          |> halt
      _ ->
        conn
    end
  end

  @spec dummy_campaign(Plug.Conn.t, any) :: Plug.Conn.t
  def dummy_campaign(%{assigns: %{controller_args: %{entry: entry}}} = conn, _) do
    conn
      |> put_arg(:campaign, %Sna.Repo.Campaign{
        entry_id: entry.id,
        name:     entry.name,
      })
  end

  @type args :: %{
    :uid                => integer,
    :entry              => Sna.Repo.Entry.t,
    optional(:campaign) => %Ecto.Changeset{data: Sna.Repo.Campaign.t}
  }

  @spec new(Plug.Conn.t, Plug.Conn.params, args) :: Plug.Conn.t
  def new(conn, params, args) do
    form(conn, params, args, "new.html")
  end

  @spec edit(Plug.Conn.t, Plug.Conn.params, args) :: Plug.Conn.t
  def edit(conn, params, args) do
    form(conn, params, args, "edit.html")
  end

  @spec form(Plug.Conn.t, Plug.Conn.params, args, String.t) :: Plug.Conn.t
  def form(conn, _params, %{entry: entry, campaign: campaign}, template) do
    # https://github.com/phoenixframework/phoenix_live_view/issues/111
    crsf_token = get_csrf_token()
    Logger.info("crsf token = #{inspect(crsf_token)}")
    conn
      |> render(template, session: %SnaWeb.EntriesCampaignLive.Form.Session{
        entry:      entry,
        campaign:   campaign,
        uid:        current_user(conn).id,
        crsf_token: crsf_token})
  end

  @spec show(Plug.Conn.t, Plug.Conn.params, args) :: Plug.Conn.t
  def show(conn, _params, %{entry: entry, campaign: campaign, uid: uid}) do
    if campaign == nil do
      conn
        |> redirect(to: Routes.entries_campaign_path(conn, :new, entry.id))
    else
      user = Sna.Repo.get(Sna.Repo.User, uid)
        |> Sna.Repo.preload(:providers)

      campaign = campaign
        |> Sna.Repo.preload(scheduled_entries: [:provider])

      conn
        |> render("show.html", entry: entry,
          campaign:  campaign,
          providers: user.providers)
    end
  end

  @spec update(Plug.Conn.t, Plug.Conn.params, args) :: Plug.Conn.t
  def update(conn, %{"campaign" => campaign_params}, %{campaign: campaign, entry: entry}) do
    changeset = (campaign || %Sna.Repo.Campaign{})
      |> Map.put(:entry_id, entry.id)
      |> Sna.Repo.Campaign.changeset(campaign_params)

    case Sna.Repo.Campaign.insert_or_update(changeset) do
      {:ok, _campaign} ->
        conn
          |> redirect(to: Routes.entries_campaign_path(conn, :show, entry.id))
      {:error, changeset} ->
        conn
          |> render("new.html", entry: entry, campaign: changeset)
    end
  end

  @spec destroy(Plug.Conn.t, Plug.Conn.params, args) :: Plug.Conn.t
  def destroy(conn, _params, %{entry: entry, campaign: campaign}) do
    case Sna.Repo.delete(campaign) do
      {:ok, _struct} ->
          conn
            |> put_flash(:info, "Destroyed campaign")
            |> redirect(to: Routes.entries_path(conn, :show, entry.id))
            |> halt()
      {:error, _changeset} ->
          conn
            |> put_flash(:error, "Could not destroy campaign")
            |> redirect(to: Routes.entries_campaign_path(conn, :show, entry.id))
            |> halt()
    end
  end
end
