import Config

config :workflow_metal_postgres_adapter,
  ecto_repos: [WorkflowMetalPostgresAdapter.Repo]

config :workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter,
  schema: "public",
  prefix: "workflow_metal"

config :workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter.Repo,
  database: "workflow_metal_postgres_adapter_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger,
  backends: [:console],
  level: :info
