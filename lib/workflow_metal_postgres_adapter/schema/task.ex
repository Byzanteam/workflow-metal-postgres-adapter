defmodule WorkflowMetalPostgresAdapter.Schema.Task do
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum(
    StateType,
    :"#{@prefix}_task_state_type",
    [:started, :allocated, :executing, :completed, :abandoned],
    schema: @schema
  )

  schema "#{@prefix}_tasks" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :case_id, Ecto.UUID
    field :state, StateType
    field :token_payload, :map

    timestamps()
  end
end
