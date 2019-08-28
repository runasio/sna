defmodule SnaWeb.EntriesCampaignLive.Form do
  use SnaWeb, :live
  require Logger

  defmodule Session do
    use TypedStruct
    typedstruct do
      field :entry,      Sna.Repo.Entry.t,    enforce: true
      field :campaign,   Sna.Repo.Campaign.t, enforce: true
      field :uid,        integer,             enforce: true
      field :crsf_token, String.t,            enforce: true
    end
  end

  @spec mount(Session.t, Phoenix.LiveView.Socket.t) :: {:ok, Phoenix.LiveView.Socket.t} | {:stop, Phoenix.LiveView.Socket.t}
  def mount(%Session{} = session, socket) do
    socket = socket
      |> assign(Map.to_list(session))
      |> assign(:campaign, session.campaign)
      |> assign(:changeset, Sna.Repo.Campaign.changeset(session.campaign))

    {:ok, socket}
  end

  def page_title(_assigns), do: "Edit Campaign"
  def view_module,          do: SnaWeb.CampaignsView
  def view_template,        do: "_form.html"
  def render(assigns),      do: render(view_module(), view_template(), assigns)

  def handle_event("validate", %{"campaign" => params}, socket) do
    changeset = socket.assigns.changeset
      |> Sna.Repo.Campaign.changeset(params)
    Logger.warn("validate = #{inspect(changeset)}")

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"campaign" => params}, socket) do
    entry_id = socket.assigns.entry.id
    changeset = Sna.Repo.Campaign.get_by_entry_id(entry_id)
      |> Kernel.||(%Sna.Repo.Campaign{entry_id: entry_id})
      |> Sna.Repo.Campaign.changeset(params)

    case Sna.Repo.Campaign.insert_or_update(changeset) do
      {:ok, _campaign} ->
        socket = socket
          |> redirect(to: Routes.entries_campaign_path(socket, :show, entry_id))
        {:stop, socket}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
