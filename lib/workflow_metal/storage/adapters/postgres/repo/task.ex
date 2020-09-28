defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Task do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def insert_task(config, task_schema) do
    schema = get_schema(Task, config)

    changeset =
      schema
      |> struct()
      |> Ecto.Changeset.cast(Map.from_struct(task_schema), [
        :id,
        :state,
        :token_payload,
        :transition_id,
        :case_id,
        :workflow_id
      ])
      |> Ecto.Changeset.validate_required([:id, :state, :transition_id, :case_id, :workflow_id])

    Multi.new()
    |> Multi.insert(:insert_task, changeset)
    |> repo_transaction(config)
    |> case do
      {:ok, %{insert_task: workflow_task}} ->
        {:ok, workflow_task}

      {:error, error} ->
        {:error, error}
    end
  end

  def fetch_task(config, task_id) do
    schema = get_schema(Task, config)

    case repo_get_by(schema, [id: task_id], config) do
      nil ->
        {:error, :task_not_found}

      workflow_task ->
        {:ok, workflow_task}
    end
  end

  def fetch_tasks(config, case_id, options) do
    import Ecto.Query

    {state, clauses} = Keyword.split(options, [:state])

    queryable =
      Task
      |> get_schema(config)
      |> where(^clauses)
      |> where(case_id: ^case_id)

    tasks =
      state
      |> case do
        [] ->
          repo_all(queryable, config)

        [state: states] ->
          queryable
          |> where([q], q.state in ^states)
          |> repo_all(config)
      end

    {:ok, tasks}
  end

  def update_task(config, task_id, params) do
    schema = get_schema(Task, config)

    changeset =
      schema
      |> struct(%{id: task_id})
      |> Ecto.Changeset.cast(params, [:state, :token_payload])
      |> Ecto.Changeset.validate_required([:state])

    Multi.new()
    |> Multi.update(:update_task, changeset)
    |> repo_transaction(config)
    |> case do
      {:ok, %{update_task: workflow_task}} ->
        {:ok, workflow_task}

      {:error, error} ->
        {:error, error}
    end
  end
end
