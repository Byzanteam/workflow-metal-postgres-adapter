defmodule TestStorage.Schema.Transition do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  transition_schema "transitions",
    join_type: TestStorage.TransitionTypes.JoinTypeEnum,
    split_type: TestStorage.TransitionTypes.SplitTypeEnum do
    timestamps()
  end
end
