defmodule Sna.Repo do
  use Ecto.Repo,
    otp_app: :sna,
    adapter: Ecto.Adapters.Postgres
end
