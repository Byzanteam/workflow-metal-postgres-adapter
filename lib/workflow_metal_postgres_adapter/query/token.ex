defmodule WorkflowMetalPostgresAdapter.Query.Token do
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Query.{Task, Workflow, Case, Place}
  alias WorkflowMetalPostgresAdapter.Schema.Token

  @genesis_uuid "00000000-0000-0000-0000-000000000000"

  @doc """
  Issue a token.

  If produced_by_task_id is `:genesis`, the token is a genesis token.
  """
  def issue_token(adapter_meta, token_params) do
    %{
      workflow_id: workflow_id,
      case_id: case_id,
      place_id: place_id,
      produced_by_task_id: produced_by_task_id
    } = token_params

    with {:ok, workflow} <- Workflow.fetch_workflow(adapter_meta, workflow_id),
         {:ok, workflow_case} <- Case.fetch_case(adapter_meta, case_id),
         {:ok, place} <- Place.fetch_place(adapter_meta, place_id),
         {:ok, produced_by_task} <- find_produced_by_task(adapter_meta, produced_by_task_id) do
      produced_by_task_id = if produced_by_task, do: produced_by_task.id, else: @genesis_uuid

      params =
        Map.merge(token_params, %{
          id: uuid(),
          workflow_id: workflow.id,
          case_id: workflow_case.id,
          place_id: place.id,
          produced_by_task_id: produced_by_task_id
        })

      repo = repo(adapter_meta)

      %Token{}
      |> Token.changeset(params)
      |> repo.insert()
    end
  end

  @doc """
  Lock tokens atomically.
  """
  def lock_tokens(adapter_meta, token_ids, locked_by_task_id) do
    with {:ok, task} <- Task.fetch_task(adapter_meta, locked_by_task_id),
         {:ok, tokens} <-
           prepare_lock_tokens(adapter_meta, token_ids) do
      do_lock_tokens(tokens, task, repo(adapter_meta))
    end
  end

  @doc """
  Unlock tokens that locked by the task.
  """
  def unlock_tokens(adapter_meta, locked_by_task_id) do
    with {:ok, task} <- Task.fetch_task(adapter_meta, locked_by_task_id) do
      tokens_query =
        from t in Token,
          where: t.state == ^:locked,
          where: t.locked_by_task_id == ^locked_by_task_id,
          where: t.case_id == ^task.case_id

      repo = repo(adapter_meta)
      tokens = repo.all(tokens_query)
      do_unlock_tokens(tokens, repo)
    end
  end

  @doc """
  Consume tokens that locked by the task.
  """
  def consume_tokens(adapter_meta, {case_id, :termination}) do
    with {:ok, case} <- Case.fetch_case(adapter_meta, case_id),
         {:ok, tokens} <- fetch_tokens(adapter_meta, case.id, states: [:free]) do
      tokens_query = from t in Token, where: t.id in ^Enum.map(tokens, & &1.id)
      repo = repo(adapter_meta)
      tokens = repo.all(tokens_query)
      do_consume_tokens(tokens, repo)
    end
  end

  def consume_tokens(adapter_meta, locked_by_task_id) do
    with {:ok, task} <- Task.fetch_task(adapter_meta, locked_by_task_id) do
      tokens_query =
        from t in Token,
          where: t.state == ^:locked,
          where: t.locked_by_task_id == ^locked_by_task_id,
          where: t.case_id == ^task.case_id

      repo = repo(adapter_meta)
      tokens = repo.all(tokens_query)
      do_consume_tokens(tokens, repo, task.id)
    end
  end

  @doc """
  Retrive tokens of the task.
  """
  def fetch_tokens(adapter_meta, case_id, fetch_tokens_options) do
    with {:ok, case} <- Case.fetch_case(adapter_meta, case_id) do
      states = Keyword.get(fetch_tokens_options, :states, [])
      locked_by_task_id = Keyword.get(fetch_tokens_options, :locked_by_task_id)

      base_query = from t in Token, where: t.case_id == ^case.id, where: t.state in ^states

      query =
        if locked_by_task_id do
          from q in base_query, where: q.locked_by_task_id == ^locked_by_task_id
        else
          base_query
        end

      tokens = repo(adapter_meta).all(query)
      {:ok, tokens}
    end
  end

  defp find_produced_by_task(_adapter_meta, :genesis), do: {:ok, nil}
  defp find_produced_by_task(adapter_meta, task_id), do: Task.fetch_task(adapter_meta, task_id)

  defp prepare_lock_tokens(adapter_meta, token_ids) do
    query = from t in Token, where: t.id in ^token_ids, where: t.state == ^:free
    repo = repo(adapter_meta)
    tokens = repo.all(query)

    if length(tokens) === length(token_ids) do
      {:ok, tokens}
    else
      {:error, :tokens_not_available}
    end
  end

  defp do_lock_tokens(tokens, task, repo) do
    query = from t in Token, where: t.id in ^Enum.map(tokens, & &1.id)
    repo.update_all(query, set: [state: :locked, locked_by_task_id: task.id, updated_at: now()])
    {:ok, repo.all(query)}
  end

  defp do_unlock_tokens(tokens, repo) do
    query = from t in Token, where: t.id in ^Enum.map(tokens, & &1.id)
    repo.update_all(query, set: [state: :free, locked_by_task_id: nil, updated_at: now()])
    {:ok, repo.all(query)}
  end

  defp do_consume_tokens(tokens, repo, task_id \\ nil) do
    query = from t in Token, where: t.id in ^Enum.map(tokens, & &1.id)

    repo.update_all(query,
      set: [state: :consumed, updated_at: now(), consumed_by_task_id: task_id]
    )

    {:ok, repo.all(query)}
  end
end
