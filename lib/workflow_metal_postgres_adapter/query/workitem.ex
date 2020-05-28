defmodule WorkflowMetalPostgresAdapter.Query.Workitem do
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Schema.Workitem
  alias WorkflowMetalPostgresAdapter.Query.{Task, Workflow, Case}

  @doc """
  Create a workitem of a task.
  """
  def create_workitem(adapter_meta, workitem_params) do
    %{
      workflow_id: workflow_id,
      case_id: case_id,
      task_id: task_id
    } = workitem_params

    with {:ok, workflow} <- Workflow.fetch_workflow(adapter_meta, workflow_id),
         {:ok, workflow_case} <- Case.fetch_case(adapter_meta, case_id),
         {:ok, task} <- Task.fetch_task(adapter_meta, task_id) do
      params =
        Map.merge(workitem_params, %{
          id: uuid(),
          workflow_id: workflow.id,
          case_id: workflow_case.id,
          task_id: task.id
        })

      repo = repo(adapter_meta)

      %Workitem{}
      |> Workitem.changeset(params)
      |> repo.insert()
    end
  end

  @doc """
  Fetch a workitem of a task.
  """
  def fetch_workitem(adapter_meta, workitem_id) do
    repo = repo(adapter_meta)

    case repo.get(Workitem, workitem_id) do
      nil -> {:error, :workitem_not_found}
      workitem -> {:ok, workitem}
    end
  end

  @doc """
  Retrive workitems generated by the task.
  """
  def fetch_workitems(adapter_meta, task_id) do
    with {:ok, task} <- Task.fetch_task(adapter_meta, task_id) do
      query =
        from w in Workitem,
          where: w.task_id == ^task.id,
          where: w.workflow_id == ^task.workflow_id

      repo = repo(adapter_meta)
      {:ok, repo.all(query)}
    end
  end

  @doc """
  Update the workitem.

  ### update_workitem_params:
  - `:started`
  - `{:completed, workitem_output}`
  - `:abandoned`

  note: if the state of the workitem is the state in the update_workitem,
  it returns `{:ok, workitem_schema}` too.
  """
  def update_workitem(adapter_meta, workitem_id, update_workitem_params) do
    with {:ok, workitem} <- fetch_workitem(adapter_meta, workitem_id) do
      repo = repo(adapter_meta)
      try_update_workitem(repo, workitem, update_workitem_params)
    end
  end

  defp try_update_workitem(_repo, %{state: state} = workitem, state) do
    {:ok, workitem}
  end

  defp try_update_workitem(_repo, %{state: :completed} = workitem, {:completed, _workitem_output}) do
    {:ok, workitem}
  end

  defp try_update_workitem(repo, %{state: :created} = workitem, :started) do
    do_update_workitem(repo, workitem, %{state: :started})
  end

  defp try_update_workitem(repo, %{state: state} = workitem, :completed)
       when state in [:created, :started] do
    do_update_workitem(repo, workitem, %{state: :completed})
  end

  defp try_update_workitem(repo, %{state: state} = workitem, :abandoned)
       when state in [:created, :started] do
    do_update_workitem(repo, workitem, %{state: :abandoned})
  end

  defp try_update_workitem(_repo, _workitem, _update_workitem_params) do
    {:error, :workitem_not_available}
  end

  defp do_update_workitem(repo, workitem, params) do
    workitem
    |> Ecto.Changeset.change(params)
    |> repo.update()
  end
end
