defmodule WorkflowMetalPostgresAdapter.Schema.Arc do
  @moduledoc """
  Present an arc.

  ## Example
  [A(place)] -1-> [B(transition)] -2-> [C(place)]

  ```elixir
    %__MODULE__{
      id: "id-1"
      workflow_id: "workflow_id"
      place_id: A
      transition_id: B
      direction: :out,
    }
    %__MODULE__{
      id: "id-2"
      workflow_id: "workflow_id"
      place_id: C
      transition_id: B
      direction: :in,
    }
  ```
  """
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum(DirectionType, :"#{@prefix}_arc_direction", [:in, :out], schema: @schema)

  schema "#{@prefix}_arcs" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :place_id, Ecto.UUID
    field :direction, DirectionType

    timestamps(updated_at: false)
  end
end
