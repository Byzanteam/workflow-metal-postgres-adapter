defmodule WorkflowMetalPostgresAdapter.Schema.Case do
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum StateType, :"#{@prefix}_case_state_type", [:created, :active, :canceled, :finished], schema: @schema

  schema "#{@prefix}_cases" do
    field :workflow_id, Ecto.UUID
    field :state, StateType

    timestamps()
  end
end
