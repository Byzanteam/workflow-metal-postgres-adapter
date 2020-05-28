defmodule WorkflowMetalPostgresAdapter.Schema.Workflow do
  use Ecto.Schema

  import EctoEnum
  defenum StateEnum, :workflow_state, [:active, :discarded]

  schema "workflow_workflows" do
    field :state, StateEnum

    timestamps(updated_at: false)
  end
end
