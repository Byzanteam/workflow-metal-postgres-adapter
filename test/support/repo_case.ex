defmodule WorkflowMetalPostgresAdapter.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias WorkflowMetalPostgresAdapter.Repo

      import Ecto
      import Ecto.Query
      import WorkflowMetalPostgresAdapter.RepoCase

      @adapter_meta [
        repo: WorkflowMetalPostgresAdapter.Repo,
        enum_types: [
          transition: [
            split_type: WorkflowMetalPostgresAdapter.Support.TransitionTypes.SplitTypeEnum,
            join_type: WorkflowMetalPostgresAdapter.Support.TransitionTypes.JoinTypeEnum
          ]
        ]
      ]
      # and any other stuff
    end
  end

  setup tags do
    alias WorkflowMetalPostgresAdapter.Repo
    alias Ecto.Adapters.SQL.Sandbox
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
