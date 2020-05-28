defmodule WorkflowMetalPostgresAdapter.Schema.Transition do

  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum
  defenum JoinType, :"#{@prefix}_transition_join_type", [:none, :and], schema: @schema
  defenum SplitType, :"#{@prefix}_transition_split_type", [:none, :and], schema: @schema

  schema "#{@prefix}_transitions" do
    field :workflow_id, Ecto.UUID
    field :join_type, JoinType
    field :split_type, SplitType
    field :executor, :string
    field :executor_params, :map

    timestamps(updated_at: false)
  end
end
