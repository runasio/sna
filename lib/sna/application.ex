defmodule Sna.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Sna.Repo,
      SnaWeb.Endpoint,
      Sna.Auth.Supervisor,
    ]

    opts = [strategy: :one_for_one, name: Sna.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SnaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
