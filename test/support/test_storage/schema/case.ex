defmodule TestStorage.Schema.Case do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  case_schema "cases" do
    timestamps()
  end
end
