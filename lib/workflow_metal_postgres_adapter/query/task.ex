defmodule WorkflowMetalPostgresAdapter.Query.Task do
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Schema.Task
  alias WorkflowMetalPostgresAdapter.Query.{Workflow, Transition, Case}

  def create_task(adapter_meta, task_params) do
    %{
      workflow_id: workflow_id,
      transition_id: transition_id,
      case_id: case_id
    } = task_params

    with {:ok, workflow} <- Workflow.fetch_workflow(adapter_meta, workflow_id),
         {:ok, transition} <- Transition.fetch_transition(adapter_meta, transition_id),
         {:ok, workflow_case} <- Case.fetch_case(adapter_meta, case_id) do
      params =
        Map.merge(task_params, %{
          id: uuid(),
          workflow_id: workflow.id,
          transition_id: transition.id,
          case_id: workflow_case.id
        })

      repo = repo(adapter_meta)
      repo.insert(Task.changeset(%Task{}, params))
    end
  end

  def fetch_task(adapter_meta, task_id) do
    repo = repo(adapter_meta)

    case repo.get(Task, task_id) do
      nil ->
        {:error, :task_not_found}

      task ->
        {:ok, task}
    end
  end

  def fetch_tasks(adapter_meta, case_id, fetch_tasks_options) do
    with {:ok, case} <- Case.fetch_case(adapter_meta, case_id) do
      states = Keyword.get(fetch_tasks_options, :states, [])
      transition_id = Keyword.get(fetch_tasks_options, :transition_id)

      base_query = from t in Task, where: t.case_id == ^case.id, where: t.state in ^states

      query =
        if transition_id do
          from q in base_query, where: q.transition_id == ^transition_id
        else
          base_query
        end

      tasks = repo(adapter_meta).all(query)

      {:ok, tasks}
    end
  end

  def update_task(adapter_meta, task_id, update_task_params) do
    with {:ok, task} <- fetch_task(adapter_meta, task_id) do
      repo = repo(adapter_meta)

      try_update_task(repo, task, update_task_params)
    end
  end

  defp try_update_task(_repo, %{state: state} = task, state) do
    {:ok, task}
  end

  defp try_update_task(_repo, %{state: :completed} = task, {:completed, _token_payload}) do
    {:ok, task}
  end

  defp try_update_task(repo, %{state: :started} = task, :allocated) do
    do_update_task(repo, task, %{state: :allocated})
  end

  defp try_update_task(repo, %{state: :allocated} = task, :executing) do
    do_update_task(repo, task, %{state: :executing})
  end

  defp try_update_task(repo, %{state: :executing} = task, {:completed, token_payload}) do
    do_update_task(repo, task, %{state: :completed, token_payload: token_payload})
  end

  defp try_update_task(repo, %{state: state} = task, :abandoned)
       when state in [:started, :allocated, :executing] do
    do_update_task(repo, task, %{state: :abandoned})
  end

  defp try_update_task(_repo, _task, _update_task_params) do
    {:error, :task_not_available}
  end

  defp do_update_task(repo, task, params) do
    task
    |> Ecto.Changeset.change(params)
    |> repo.update()
  end
end
