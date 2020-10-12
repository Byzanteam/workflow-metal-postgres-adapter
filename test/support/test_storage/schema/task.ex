defmodule TestStorage.Schema.Task do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  task_schema "tasks" do
    timestamps()
  end
end
