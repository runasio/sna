defmodule Sna.MixProject do
  use Mix.Project

  def project() do
    [
      app: :sna,
      name: "SNA",
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext, :phoenix_swagger] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      source_url: "https://github.com/runas/sna",
      homepage_url: "http://runas.io",
      description: description(),
      package: package(),
    ]
  end

  def application() do
    [
      mod: {Sna.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/mocks"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps() do
    [
      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},

      # Latest master fixes a compatibility issue with Phoenix, not released yet
      # https://github.com/xerions/phoenix_swagger/issues/232
      # Need version strictly greater than 0.8.1
      {:phoenix_swagger, git: "https://github.com/xerions/phoenix_swagger.git", tag: "master"},

      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.1"},
      {:gettext, "~> 0.11"},
      {:joken, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:gen_state_machine, "~> 2.0"},
      {:httpoison, "~> 1.4"},
      {:ex_json_schema, "~> 0.6"},
      {:swoosh, "~> 0.23"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_github, "~> 0.7"},

      # Should not be needed as we have jason instead, but:
      # https://github.com/ueberauth/ueberauth_github/issues/50
      {:poison, "~> 3.1"},
    ]
  end

  defp aliases() do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp description() do
    "Social Network Authentication frontend and backend."
  end

  defp package() do
    [
      name: "sna",
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/runasio/sna"}
    ]
  end
end
