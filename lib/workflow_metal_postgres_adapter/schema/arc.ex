defmodule WorkflowMetalPostgresAdapter.Schema.Arc do
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum DirectionType, :"#{@prefix}_arc_direction", [:in, :out], schema: @schema

  schema "#{@prefix}_arcs" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :place_id, Ecto.UUID
    field :direction, DirectionType

    timestamps(updated_at: false)
  end
end
