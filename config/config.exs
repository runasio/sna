# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sna,
  ecto_repos: [Sna.Repo]

config :ueberauth, Ueberauth,
  json_library: Jason

Mix.Config.config :ueberauth, Ueberauth.Strategy.Github.OAuth,
   client_id: System.get_env("GITHUB_CLIENT_ID"),
   client_secret: System.get_env("GITHUB_CLIENT_SECRET");

# Configures the endpoint
config :sna, SnaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DPSxmdG6g232bXq8aHZ0J1eTZmCyUPYU5VbcO1GXk3McfYj+hfOokRpXKmg0u2It",
  render_errors: [view: SnaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Sna.PubSub, adapter: Phoenix.PubSub.PG2]

config :sna, :oauth_providers,
  github: Ueberauth.Strategy.Github

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
