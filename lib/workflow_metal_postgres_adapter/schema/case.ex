defmodule WorkflowMetalPostgresAdapter.Schema.Case do
  @moduledoc """
  ## State
  - `:created`: the case is just created, we'll put a token in the `:start` place
  - `:active`: the case is running
  - `:canceled`: the case can be canceled by a user who created it or the system
  - `:finished`: when there is only one token left in the `:end` place
  """
  use WorkflowMetalPostgresAdapter.Schema

  import EctoEnum

  defenum(StateType, :"#{@prefix}_case_state_type", [:created, :active, :canceled, :finished],
    schema: @schema
  )

  schema "#{@prefix}_cases" do
    field :workflow_id, Ecto.UUID
    field :state, StateType

    timestamps()
  end
end
