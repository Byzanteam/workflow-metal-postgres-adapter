defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Case do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def insert_case(config, case_schema) do
    schema = get_schema(Case, config)

    changeset =
      schema
      |> struct()
      |> Ecto.Changeset.cast(Map.from_struct(case_schema), [:id, :state, :workflow_id])
      |> Ecto.Changeset.validate_required([:id, :state, :workflow_id])

    Multi.new()
    |> Multi.insert(:insert_case, changeset)
    |> repo_transaction(config)
    |> case do
      {:ok, %{insert_case: workflow_case}} ->
        {:ok, workflow_case}

      {:error, error} ->
        {:error, error}
    end
  end

  def fetch_case(config, case_id) do
    schema = get_schema(Case, config)

    case repo_get_by(schema, [id: case_id], config) do
      nil ->
        {:error, :case_not_found}

      workflow_case ->
        {:ok, workflow_case}
    end
  end

  def update_case(config, case_id, params) do
    schema = get_schema(Case, config)

    changeset =
      schema
      |> struct(%{id: case_id})
      |> Ecto.Changeset.cast(params, [:state])
      |> Ecto.Changeset.validate_required([:state])

    Multi.new()
    |> Multi.update(:update_case, changeset)
    |> repo_transaction(config)
    |> case do
      {:ok, %{update_case: workflow_case}} ->
        {:ok, workflow_case}

      {:error, error} ->
        {:error, error}
    end
  end
end
