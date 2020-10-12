defmodule TestStorage.Schema.Arc do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  arc_schema "arcs" do
    timestamps()
  end
end
