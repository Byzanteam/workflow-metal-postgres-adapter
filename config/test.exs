import Config

config :workflow_metal_postgres_adapter,
  ecto_repos: [TestStorage.Repo]

config :workflow_metal_postgres_adapter, TestStorage.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "ecto://postgres:postgres@localhost/workflow_metal_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]
