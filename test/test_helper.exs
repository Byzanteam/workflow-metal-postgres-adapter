ExUnit.start()

WorkflowMetalPostgresAdapter.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(WorkflowMetalPostgresAdapter.Repo, :manual)
