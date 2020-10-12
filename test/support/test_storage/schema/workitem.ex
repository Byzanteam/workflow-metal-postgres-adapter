defmodule TestStorage.Schema.Workitem do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  workitem_schema "workitems" do
    timestamps()
  end
end
