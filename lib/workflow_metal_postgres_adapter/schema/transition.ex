defmodule WorkflowMetalPostgresAdapter.Schema.Transition do
  @moduledoc """
  Present a transition.
  """

  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetalPostgresAdapter.Schema.ExecutorType
  alias WorkflowMetal.Storage.Schema.Transition

  import EctoEnum

  @split_type Application.compile_env(:workflow_metal_postgres_adapter, [:transition, :split_type]) ||
                [none: 0, and: 1]
  @join_type Application.compile_env(:workflow_metal_postgres_adapter, [:transition, :join_type]) ||
               [none: 0, and: 1]

  defenum SplitType, @split_type
  defenum JoinType, @join_type

  schema "#{@prefix}_transitions" do
    field :workflow_id, Ecto.UUID
    field :join_type, JoinType
    field :split_type, SplitType
    field :executor, ExecutorType
    field :executor_params, :map
    field :metadata, :map

    timestamps(updated_at: false)
  end

  def to_storage_schema(transition) do
    %Transition{
      id: transition.id,
      workflow_id: transition.workflow_id,
      join_type: transition.join_type,
      split_type: transition.split_type,
      executor: transition.executor,
      executor_params: transition.executor_params,
      metadata: transition.metadata
    }
  end
end
