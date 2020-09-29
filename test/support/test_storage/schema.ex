defmodule TestStorage.Schema do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  workflow_schema "workflows" do
    timestamps()
  end

  place_schema "places" do
    timestamps()
  end

  transition_schema "transitions",
    join_type: TestStorage.TransitionTypes.JoinTypeEnum,
    split_type: TestStorage.TransitionTypes.SplitTypeEnum do
    timestamps()
  end

  arc_schema "arcs" do
    timestamps()
  end

  case_schema "cases" do
    timestamps()
  end

  token_schema "tokens" do
    timestamps()
  end

  task_schema "tasks" do
    timestamps()
  end

  workitem_schema "workitems" do
    timestamps()
  end
end
