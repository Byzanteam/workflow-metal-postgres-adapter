defmodule WorkflowMetalPostgresAdapter.Schema.Place do

  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum TypeEnum, :"#{@prefix}_place_type", [:start, :normal, :end], schema: @schema

  schema "#{@prefix}_places" do
    field :workflow_id, Ecto.UUID
    field :type, TypeEnum

    timestamps(updated_at: false)
  end
end
