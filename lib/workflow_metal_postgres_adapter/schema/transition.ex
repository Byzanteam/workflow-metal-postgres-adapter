defmodule WorkflowMetalPostgresAdapter.Schema.Transition do
  @moduledoc """
  Present a transition.
  """

  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetalPostgresAdapter.Schema.ExecutorType
  alias WorkflowMetal.Storage.Schema.Transition

  schema "#{@prefix}_transitions" do
    field :workflow_id, Ecto.UUID
    field :join_type, :integer
    field :split_type, :integer
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
