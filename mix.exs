defmodule WorkflowMetalPostgresAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :workflow_metal_postgres_adapter,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_per_environment: is_nil(System.get_env("GITHUB_ACTIONS")),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:doctor, "~> 0.12.0", only: [:dev]},
      {:ecto, "~> 3.1"},
      {:ecto_sql, "~> 3.1"},
      {:jason, "~> 1.1"},
      {:postgrex, "~> 0.14"},
      {:ecto_enum, "~> 1.4"}
    ]
  end

  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/support",
      "test/helpers"
    ]

  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "code.check": ["format --check-formatted", "doctor --summary", "credo --strict", "dialyzer"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
