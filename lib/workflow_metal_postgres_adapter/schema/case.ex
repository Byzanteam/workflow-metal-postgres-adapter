defmodule WorkflowMetalPostgresAdapter.Schema.Case do
  @moduledoc """
  ## State
  - `:created`: the case is just created, we'll put a token in the `:start` place
  - `:active`: the case is running
  - `:canceled`: the case can be canceled by a user who created it or the system
  - `:finished`: when there is only one token left in the `:end` place
  """
  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetal.Storage.Schema.Case

  import EctoEnum

  defenum(StateType, :"#{@prefix}_case_state_type", [:created, :active, :canceled, :finished],
    schema: @schema
  )

  schema "#{@prefix}_cases" do
    field :workflow_id, Ecto.UUID
    field :state, StateType
    field :data, :map

    timestamps()
  end

  def changeset(case, params) do
    case
    |> cast(params, [:workflow_id, :id, :state, :data])
    |> validate_required([:id, :workflow_id, :state])
  end

  def to_storage_schema(case) do
    %Case{
      id: case.id,
      workflow_id: case.workflow_id,
      state: case.state,
      data: case.data
    }
  end
end
