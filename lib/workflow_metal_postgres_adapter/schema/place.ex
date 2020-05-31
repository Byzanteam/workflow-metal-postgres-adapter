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

  import EctoEnum

  defenum(TypeEnum, :"#{@prefix}_place_type", [:start, :normal, :end], schema: @schema)

  schema "#{@prefix}_places" do
    field :workflow_id, Ecto.UUID
    field :type, TypeEnum

    timestamps(updated_at: false)
  end
end
