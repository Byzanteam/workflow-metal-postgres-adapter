defmodule WorkflowMetalPostgresAdapter.Schema.Workflow do
  @moduledoc """
  Present a workflow.
  """
  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetalPostgresAdapter.Schema.{Place, Transition, Arc}

  import EctoEnum
  defenum(StateEnum, :"#{@prefix}workflow_state", [:active, :discarded], schema: @schema)

  schema "#{@prefix}_workflows" do
    field :state, StateEnum

    has_many :places, Place
    has_many :transitions, Transition
    has_many :arcs, Arc

    timestamps(updated_at: false)
  end
end
