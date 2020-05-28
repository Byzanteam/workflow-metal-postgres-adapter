import Config

config :workflow_metal_postgres_adapter,
  ecto_repos: [WorkflowMetalPostgresAdapter.Repo]

config :workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter,
  repo: WorkflowMetalPostgresAdapter.Repo,
  schema: "public",
  prefix: "workflow_metal"

import_config "#{Mix.env()}.exs"
