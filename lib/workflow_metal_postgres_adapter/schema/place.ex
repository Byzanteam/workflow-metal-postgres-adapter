defmodule WorkflowMetalPostgresAdapter.Schema.Place do
  @moduledoc """
  Present a place.

  There is one `:start`, one `:end`, and several `:normal` places in a workflow.

  ## Type

  - `:normal`
  - `:start`
  - `:end`
  """

  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetal.Storage.Schema.Place

  import EctoEnum

  defenum TypeEnum, [
    start: 0,
    normal: 1,
    end: 2
  ]

  schema "#{@prefix}_places" do
    field :workflow_id, Ecto.UUID
    field :type, TypeEnum
    field :metadata, :map

    timestamps(updated_at: false)
  end

  def to_storage_schema(place) do
    %Place{
      id: place.id,
      workflow_id: place.workflow_id,
      type: place.type,
      metadata: place.metadata
    }
  end
end
