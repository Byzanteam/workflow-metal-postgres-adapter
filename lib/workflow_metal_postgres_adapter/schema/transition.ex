defmodule WorkflowMetalPostgresAdapter.Schema.Transition do
  @moduledoc """
  Present a transition.
  """

  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetalPostgresAdapter.Schema.ExecutorType

  import EctoEnum
  defenum(JoinType, :"#{@prefix}_transition_join_type", [:none, :and], schema: @schema)
  defenum(SplitType, :"#{@prefix}_transition_split_type", [:none, :and], schema: @schema)

  schema "#{@prefix}_transitions" do
    field :workflow_id, Ecto.UUID
    field :join_type, JoinType
    field :split_type, SplitType
    field :executor, ExecutorType
    field :executor_params, :map

    timestamps(updated_at: false)
  end
end
