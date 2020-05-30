defmodule WorkflowMetalPostgresAdapter.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias WorkflowMetalPostgresAdapter.Repo

      import Ecto
      import Ecto.Query
      import WorkflowMetalPostgresAdapter.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WorkflowMetalPostgresAdapter.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(WorkflowMetalPostgresAdapter.Repo, {:shared, self()})
    end

    :ok
  end
end
