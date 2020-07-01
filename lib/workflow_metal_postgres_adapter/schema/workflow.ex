defmodule WorkflowMetalPostgresAdapter.Schema.Workflow do
  @moduledoc """
  Present a workflow.
  """
  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetalPostgresAdapter.Schema.{Place, Transition, Arc}
  alias WorkflowMetal.Storage.Schema.Workflow

  import EctoEnum

  defenum StateEnum, [
    active: 0,
    discarded: 1
  ]

  schema "#{@prefix}_workflows" do
    field :state, StateEnum

    has_many :places, Place
    has_many :transitions, Transition
    has_many :arcs, Arc

    field :metadata, :map

    timestamps(updated_at: false)
  end

  def to_storage_schema(workflow) do
    %Workflow{
      id: workflow.id,
      state: workflow.state,
      metadata: workflow.metadata
    }
  end
end
