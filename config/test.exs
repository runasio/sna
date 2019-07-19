use Mix.Config

# Configure your database
config :sna, Sna.Repo,
  username: "postgres",
  password: "postgres",
  database: "sna_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sna, SnaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :sna, Sna.Mailer,
  adapter: Bamboo.TestAdapter
