defmodule WorkflowMetalPostgresAdapter.Query.Case do
  @moduledoc false
  import WorkflowMetalPostgresAdapter.Query.Helper

  alias WorkflowMetalPostgresAdapter.Schema.Case
  alias WorkflowMetalPostgresAdapter.Query.Workflow

  def create_case(adapter_meta, case_params) do
    %{workflow_id: workflow_id} = case_params

    with {:ok, workflow} <- Workflow.fetch_workflow(adapter_meta, workflow_id) do
      workflow_case = %Case{
        id: uuid(),
        workflow_id: workflow.id,
        state: :created
      }

      repo = repo(adapter_meta)

      repo.insert(workflow_case, prefix: repo_schema())
    end
  end

  def fetch_case(adapter_meta, case_id) do
    repo = repo(adapter_meta)

    case repo.get(Case, case_id, prefix: repo_schema()) do
      nil ->
        {:error, :case_not_found}

      workflow_case ->
        {:ok, workflow_case}
    end
  end

  def update_case(adapter_meta, case_id, update_case_params) do
    with {:ok, workflow_case} <- fetch_case(adapter_meta, case_id) do
      repo = repo(adapter_meta)
      try_update_case(repo, workflow_case, update_case_params)
    end
  end

  defp try_update_case(_repo, %{state: state} = workflow_case, state) do
    {:ok, workflow_case}
  end

  defp try_update_case(repo, %{state: :created} = workflow_case, :active) do
    do_update_case(repo, workflow_case, :active)
  end

  defp try_update_case(repo, %{state: :active} = workflow_case, :finished) do
    do_update_case(repo, workflow_case, :finished)
  end

  defp try_update_case(repo, %{state: state} = workflow_case, :canceled)
       when state in [:created, :active] do
    do_update_case(repo, workflow_case, :canceled)
  end

  defp try_update_case(_repo, _workflow_case, _update_case_params) do
    {:error, :case_not_available}
  end

  defp do_update_case(repo, workflow_case, state) do
    workflow_case
    |> Ecto.Changeset.change(%{state: state})
    |> repo.update(prefix: repo_schema())
  end
end
