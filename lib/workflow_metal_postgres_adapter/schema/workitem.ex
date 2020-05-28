
defmodule WorkflowMetalPostgresAdapter.Schema.Workitem do
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum StateType, :"#{@prefix}_workitem_state_type", [:created, :started, :completed, :abandoned], schema: @schema

  schema "#{@prefix}_workitems" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :case_id, Ecto.UUID
    field :task_id, Ecto.UUID
    field :state, StateType
    field :output, :map

    timestamps()
  end
end
