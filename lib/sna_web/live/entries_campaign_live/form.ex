defmodule SnaWeb.EntriesCampaignLive.Form do
  use SnaWeb, :live
  require Logger

  def mount(session, socket) do
    {:ok, assign(socket, session)}
  end

  def render(assigns), do: Phoenix.View.render(SnaWeb.EntriesCampaignView, "_form.html", assigns)

  def handle_event("validate", %{"campaign" => params}, socket) do
    campaign = %Sna.Repo.Campaign{}
      |> Sna.Repo.Campaign.changeset(params)

    {:noreply, assign(socket, campaign: campaign)}
  end

  def handle_event("save", %{"campaign" => params}, socket) do
    entry_id = socket.assigns.entry.id
    campaign = Sna.Repo.Campaign.get_by_entry_id(entry_id)
      |> Kernel.||(%Sna.Repo.Campaign{entry_id: entry_id})
      |> Sna.Repo.Campaign.changeset(params)

    case Sna.Repo.Campaign.insert_or_update(campaign) do
      {:ok, _campaign} ->
        socket = socket
          |> redirect(to: Routes.entries_campaign_path(socket, :show, entry_id))
        {:stop, socket}
      {:error, campaign} ->
        {:noreply, assign(socket, campaign: campaign)}
    end
  end
end
