defmodule WorkflowMetalPostgresAdapter.Schema.Token do
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum StateType, :"#{@prefix}_token_state", [:free, :locked, :consumed], schema: @schema

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
end
