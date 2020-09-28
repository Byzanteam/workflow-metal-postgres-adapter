defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Case do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def insert_case(config, case_schema) do
    schema = get_schema(Case, config)

    schema
    |> struct()
    |> Ecto.Changeset.cast(Map.from_struct(case_schema), [:id, :state, :workflow_id])
    |> Ecto.Changeset.validate_required([:id, :state, :workflow_id])
    |> repo_insert(config)
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

    schema
    |> struct(%{id: case_id})
    |> Ecto.Changeset.cast(params, [:state])
    |> Ecto.Changeset.validate_required([:state])
    |> repo_update(config)
  end
end
