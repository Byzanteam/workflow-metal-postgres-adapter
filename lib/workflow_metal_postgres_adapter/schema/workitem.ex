defmodule WorkflowMetalPostgresAdapter.Schema.Workitem do
  @moduledoc false
  use WorkflowMetalPostgresAdapter.Schema

  alias WorkflowMetal.Storage.Schema.Workitem

  import EctoEnum

  defenum StateType,
    created: 0,
    started: 1,
    completed: 2,
    abandoned: 3

  schema "#{@prefix}_workitems" do
    field :workflow_id, Ecto.UUID
    field :transition_id, Ecto.UUID
    field :case_id, Ecto.UUID
    field :task_id, Ecto.UUID
    field :state, StateType, default: :created
    field :output, :map

    timestamps()
  end

  @permit_fields [
    :id,
    :workflow_id,
    :transition_id,
    :case_id,
    :task_id,
    :output,
    :state
  ]

  def changeset(workitem, params) when is_struct(params) do
    changeset(workitem, Map.from_struct(params))
  end

  def changeset(workitem, params) do
    workitem
    |> cast(params, @permit_fields)
  end

  def to_storage_schema(workitem) do
    %Workitem{
      id: workitem.id,
      workflow_id: workitem.workflow_id,
      transition_id: workitem.transition_id,
      case_id: workitem.case_id,
      task_id: workitem.task_id,
      output: workitem.output,
      state: workitem.state
    }
  end
end
