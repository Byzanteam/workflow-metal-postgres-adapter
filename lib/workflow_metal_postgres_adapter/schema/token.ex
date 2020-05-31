defmodule WorkflowMetalPostgresAdapter.Schema.Token do
  @moduledoc """
  `:genesis` the first token.
  `:termination` the last token.
  """
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum(StateType, :"#{@prefix}_token_state", [:free, :locked, :consumed], schema: @schema)

  schema "#{@prefix}_tokens" do
    field :workflow_id, Ecto.UUID
    field :case_id, Ecto.UUID
    field :place_id, Ecto.UUID
    field :produced_by_task_id, Ecto.UUID
    field :locked_by_task_id, Ecto.UUID
    field :consumed_by_task_id, Ecto.UUID
    field :state, StateType
    field :payload, :map

    timestamps()
  end

  @permit_fields [
    :id,
    :workflow_id,
    :case_id,
    :place_id,
    :produced_by_task_id,
    :locked_by_task_id,
    :consumed_by_task_id,
    :payload,
    :state
  ]

  @require_fields [
    :id,
    :state,
    :workflow_id,
    :case_id,
    :place_id,
    :produced_by_task_id
  ]

  def changeset(token, params) do
    token
    |> cast(params, @permit_fields)
    |> validate_required(@require_fields)
  end
end
