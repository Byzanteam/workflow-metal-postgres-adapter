defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Case do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def insert_case(config, case_schema) do
    changeset =
      Case
      |> get_schema(config)
      |> struct()
      |> Ecto.Changeset.cast(Map.from_struct(case_schema), [:id, :state, :workflow_id])

    pk_name = get_pk_name(Case, config)

    changeset
    |> Ecto.Changeset.get_field(:id)
    |> case do
      nil ->
        Ecto.Changeset.change(changeset, %{id: Ecto.UUID.generate()})

      _ ->
        changeset
    end
    |> Ecto.Changeset.validate_required([:id, :state, :workflow_id])
    |> Ecto.Changeset.unique_constraint(:id, name: pk_name)
    |> repo_insert(config)
    |> case do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        if Enum.any?(
             changeset.errors,
             &match?({:id, {_msg, [constraint: :unique, constraint_name: ^pk_name]}}, &1)
           ) do
          {:error, :already_exists}
        else
          {:error, changeset}
        end
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

    schema
    |> struct(%{id: case_id})
    |> Ecto.Changeset.cast(params, [:state])
    |> Ecto.Changeset.validate_required([:state])
    |> repo_update(config)
  end
end
