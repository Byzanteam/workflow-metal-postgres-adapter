defmodule WorkflowMetalPostgresAdapter.Schema.Task do
  @moduledoc false
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
    field :state, StateType, default: :started
    field :token_payload, {:array, :map}

    timestamps()
  end

  @permit_fields [
    :id,
    :workflow_id,
    :transition_id,
    :case_id,
    :token_payload,
    :state
  ]

  @required_fields [
    :id,
    :workflow_id,
    :transition_id,
    :case_id,
    :state
  ]

  def changeset(task, params) do
    task
    |> cast(params, @permit_fields)
    |> validate_required(@required_fields)
  end
end
