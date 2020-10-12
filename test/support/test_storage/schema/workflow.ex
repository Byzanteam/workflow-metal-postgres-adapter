defmodule TestStorage.Schema.Workflow do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  workflow_schema "workflows" do
    timestamps()
  end
end
