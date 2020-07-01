defmodule WorkflowMetalPostgresAdapter.Schema.Task do
  @moduledoc false
  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetal.Storage.Schema.Task

  import EctoEnum

  defenum StateType,
    started: 0,
    allocated: 1,
    executing: 2,
    completed: 3,
    abandoned: 4

  schema "#{@prefix}_tasks" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :case_id, Ecto.UUID
    field :state, StateType, default: :started
    field :token_payload, :map

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

  def changeset(task, params) when is_struct(params) do
    changeset(task, Map.from_struct(params))
  end

  def changeset(task, params) do
    task
    |> cast(params, @permit_fields)
    |> validate_required(@required_fields)
  end

  def to_storage_schema(task) do
    %Task{
      id: task.id,
      workflow_id: task.workflow_id,
      transition_id: task.transition_id,
      case_id: task.case_id,
      state: task.state,
      token_payload: task.token_payload
    }
  end
end
