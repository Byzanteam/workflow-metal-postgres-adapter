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

  alias WorkflowMetal.Storage.Schema.Arc

  import EctoEnum

  defenum DirectionType, [in: 0, out: 1]

  schema "#{@prefix}_arcs" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :place_id, Ecto.UUID
    field :direction, DirectionType
    field :metadata, :map

    timestamps(updated_at: false)
  end

  def to_storage_schema(arc) do
    %Arc{
      id: arc.id,
      workflow_id: arc.workflow_id,
      transition_id: arc.transition_id,
      place_id: arc.place_id,
      direction: arc.direction,
      metadata: arc.metadata
    }
  end
end
