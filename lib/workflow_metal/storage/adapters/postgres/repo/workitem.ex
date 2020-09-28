defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Workitem do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def insert_workitem(config, workitem_schema) do
    schema = get_schema(Workitem, config)

    schema
    |> struct()
    |> Ecto.Changeset.cast(Map.from_struct(workitem_schema), [
      :id,
      :state,
      :output,
      :transition_id,
      :case_id,
      :task_id,
      :workflow_id
    ])
    |> Ecto.Changeset.validate_required([
      :id,
      :state,
      :transition_id,
      :case_id,
      :task_id,
      :workflow_id
    ])
    |> repo_insert(config)
  end

  def fetch_workitem(config, workitem_id) do
    schema = get_schema(Workitem, config)

    case repo_get_by(schema, [id: workitem_id], config) do
      nil ->
        {:error, :workitem_not_found}

      workitem ->
        {:ok, workitem}
    end
  end

  def fetch_workitems(config, task_id) do
    import Ecto.Query

    workitems =
      Workitem
      |> get_schema(config)
      |> where(task_id: ^task_id)
      |> repo_all(config)

    {:ok, workitems}
  end

  def update_workitem(config, workitem_id, params) do
    schema = get_schema(Workitem, config)

    schema
    |> struct(%{id: workitem_id})
    |> Ecto.Changeset.cast(params, [:state, :output])
    |> Ecto.Changeset.validate_required([:state])
    |> repo_update(config)
  end
end
