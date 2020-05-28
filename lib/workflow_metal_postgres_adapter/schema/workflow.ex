defmodule WorkflowMetalPostgresAdapter.Schema.Workflow do
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum
  defenum StateEnum, :"#{@prefix}workflow_state", [:active, :discarded], schema: @schema

  schema "#{@prefix}_workflows" do
    field :state, StateEnum

    timestamps(updated_at: false)
  end
end
