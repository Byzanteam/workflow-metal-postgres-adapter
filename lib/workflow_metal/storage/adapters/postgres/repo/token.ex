defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Token do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  @zero_uuid "00000000-0000-0000-0000-000000000000"

  def issue_token(config, token_schema) do
    schema = get_schema(Token, config)

    token_schema =
      if token_schema.produced_by_task_id === :genesis do
        %{token_schema | produced_by_task_id: @zero_uuid}
      else
        token_schema
      end

    schema
    |> struct()
    |> Ecto.Changeset.cast(
      Map.from_struct(token_schema),
      [
        :id,
        :state,
        :payload,
        :place_id,
        :case_id,
        :produced_by_task_id,
        :workflow_id
      ]
    )
    |> Ecto.Changeset.validate_required([
      :id,
      :state,
      :place_id,
      :case_id,
      :produced_by_task_id,
      :workflow_id
    ])
    |> repo_insert(config)
  end

  def lock_tokens(config, token_ids, locked_by_task_id) do
    schema = get_schema(Token, config)

    token_ids
    |> Enum.reduce(Multi.new(), fn token_id, multi ->
      changeset =
        schema
        |> struct(%{id: token_id})
        |> Ecto.Changeset.cast(%{locked_by_task_id: locked_by_task_id}, [:locked_by_task_id])
        |> Ecto.Changeset.change(state: :locked)
        |> Ecto.Changeset.validate_required([:locked_by_task_id])

      Ecto.Multi.update(multi, {:update_token, token_id}, changeset)
    end)
    |> repo_transaction(config)
    |> case do
      {:ok, changes} ->
        {:ok, Map.values(changes)}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  def unlock_tokens(config, token_ids) do
    schema = get_schema(Token, config)

    token_ids
    |> Enum.reduce(Multi.new(), fn token_id, multi ->
      changeset =
        schema
        |> struct(%{id: token_id})
        |> Ecto.Changeset.change(locked_by_task_id: nil, state: :free)

      Ecto.Multi.update(multi, {:update_token, token_id}, changeset)
    end)
    |> repo_transaction(config)
    |> case do
      {:ok, changes} ->
        {:ok, Map.values(changes)}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  def consume_tokens(config, token_ids, consumed_by_task_id) do
    schema = get_schema(Token, config)

    consumed_by_task_id =
      if consumed_by_task_id === :termination do
        @zero_uuid
      else
        consumed_by_task_id
      end

    token_ids
    |> Enum.reduce(Multi.new(), fn token_id, multi ->
      changeset =
        schema
        |> struct(%{id: token_id})
        |> Ecto.Changeset.cast(%{consumed_by_task_id: consumed_by_task_id}, [:consumed_by_task_id])
        |> Ecto.Changeset.change(state: :consumed)
        |> Ecto.Changeset.validate_required([:consumed_by_task_id])

      Ecto.Multi.update(multi, {:update_token, token_id}, changeset)
    end)
    |> repo_transaction(config)
    |> case do
      {:ok, changes} ->
        {:ok, Map.values(changes)}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  def fetch_unconsumed_tokens(config, case_id) do
    import Ecto.Query
    schema = get_schema(Token, config)

    tokens =
      schema
      |> where(case_id: ^case_id)
      |> where([t], t.state != ^:consumed)
      |> repo_all(config)

    {:ok, tokens}
  end

  def fetch_tokens(config, token_ids) do
    import Ecto.Query
    schema = get_schema(Token, config)

    tokens =
      schema
      |> where([t], t.id in ^token_ids)
      |> repo_all(config)

    {:ok, tokens}
  end
end
