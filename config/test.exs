import Config

config :workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter.Repo,
  database: "workflow_metal_postgres_adapter_test_repo",
  username: "zj",
  # password: "pass",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger,
  backends: [:console],
  level: :info
