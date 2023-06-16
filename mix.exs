defmodule WorkflowMetalPostgresAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :workflow_metal_postgres_adapter,
      version: "0.3.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_per_environment: is_nil(System.get_env("GITHUB_ACTIONS")),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      dialyzer: [plt_file: {:no_warn, "priv/plts/dialyzer.plt"}]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: application(Mix.env())]
  end

  defp application(:test) do
    [:postgrex, :ecto, :logger]
  end

  defp application(_) do
    [:logger]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:doctor, "~> 0.12.0", only: [:dev]},
      {:ecto_sql, "~> 3.9"},
      {:jason, "~> 1.1"},
      {:postgrex, "~> 0.16"},
      {:workflow_metal, [github: "Byzanteam/workflow_metal", branch: "main"]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:jet_credo, [github: "Byzanteam/jet_credo", only: [:dev, :test], runtime: false]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/support", "test/helpers"]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end

  defp aliases do
    [
      "code.check": ["format --check-formatted", "doctor --summary", "credo --strict", "dialyzer"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
