defmodule WorkflowMetalPostgresAdapter.Schema.Token do
  @moduledoc """
  `:genesis` the first token.
  `:termination` the last token.
  """
  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetal.Storage.Schema.Token

  import EctoEnum

  defenum(StateType, :"#{@prefix}_token_state", [:free, :locked, :consumed], schema: @schema)

  schema "#{@prefix}_tokens" do
    field :workflow_id, Ecto.UUID
    field :case_id, Ecto.UUID
    field :place_id, Ecto.UUID
    field :produced_by_task_id, Ecto.UUID
    field :locked_by_task_id, Ecto.UUID
    field :consumed_by_task_id, Ecto.UUID
    field :state, StateType, default: :free
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

  def changeset(token, params) when is_struct(params) do
    changeset(token, Map.from_struct(params))
  end

  def changeset(token, params) do
    token
    |> cast(params, @permit_fields)
    |> validate_required(@require_fields)
  end

  def to_storage_schema(token) do
    %Token{
      id: token.id,
      workflow_id: token.workflow_id,
      case_id: token.case_id,
      place_id: token.place_id,
      produced_by_task_id: token.produced_by_task_id,
      locked_by_task_id: token.locked_by_task_id,
      consumed_by_task_id: token.consumed_by_task_id,
      payload: token.payload,
      state: token.state
    }
  end
end
