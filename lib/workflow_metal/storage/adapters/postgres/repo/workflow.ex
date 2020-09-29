defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Workflow do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def insert_workflow(config, workflow_schema, workflow_associations_params) do
    %{
      places: places,
      transitions: transitions,
      arcs: arcs
    } = workflow_associations_params

    Multi.new()
    |> do_insert_workflow(workflow_schema, config)
    |> do_insert_places(places, config)
    |> do_insert_transitions(transitions, config)
    |> do_insert_arcs(arcs, config)
    |> repo_transaction(config)
    |> case do
      {:ok, %{workflow: workflow}} ->
        {:ok, workflow}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp do_insert_workflow(multi, workflow_schema, config) do
    params = Map.from_struct(workflow_schema)

    changeset =
      Workflow
      |> get_schema(config)
      |> struct()
      |> Ecto.Changeset.cast(params, [:id, :state])
      |> Ecto.Changeset.validate_required([:id, :state])

    multi
    |> Multi.insert(:workflow, changeset)
  end

  defp do_insert_places(multi, place_schemas, config) do
    schema =
      Place
      |> get_schema(config)
      |> struct()

    place_schemas
    |> Enum.reduce(multi, fn place_schema, acc ->
      Multi.insert(acc, {:place, place_schema.id}, fn %{workflow: workflow} ->
        schema
        |> Ecto.Changeset.cast(Map.from_struct(place_schema), [:id, :type, :metadata])
        |> Ecto.Changeset.validate_required([:id, :type])
        |> Ecto.Changeset.put_assoc(:workflow, workflow)
      end)
    end)
  end

  defp do_insert_transitions(multi, transition_schemas, config) do
    schema =
      Transition
      |> get_schema(config)
      |> struct()

    transition_schemas
    |> Enum.reduce(multi, fn transition_schema, acc ->
      Multi.insert(acc, {:transition, transition_schema.id}, fn %{workflow: workflow} ->
        schema
        |> Ecto.Changeset.cast(
          Map.from_struct(transition_schema),
          [:id, :join_type, :split_type, :executor, :executor_params, :metadata]
        )
        |> Ecto.Changeset.validate_required([:id, :join_type, :split_type, :executor])
        |> Ecto.Changeset.put_assoc(:workflow, workflow)
      end)
    end)
  end

  defp do_insert_arcs(multi, arc_schemas, config) do
    schema =
      Arc
      |> get_schema(config)
      |> struct()

    arc_schemas
    |> Enum.reduce(multi, fn arc_schema, acc ->
      place_key = {:place, arc_schema.place_id}
      transition_key = {:transition, arc_schema.transition_id}

      Multi.insert(acc, {arc_schema.id, :arc}, fn changes ->
        %{
          :workflow => workflow,
          ^place_key => place,
          ^transition_key => transition
        } = changes

        schema
        |> Ecto.Changeset.cast(Map.from_struct(arc_schema), [:id, :direction, :metadata])
        |> Ecto.Changeset.validate_required([:id, :direction])
        |> Ecto.Changeset.put_assoc(:workflow, workflow)
        |> Ecto.Changeset.put_assoc(:place, place)
        |> Ecto.Changeset.put_assoc(:transition, transition)
      end)
    end)
  end

  def fetch_workflow(config, workflow_id) do
    repo = get_repo(config)
    schema = get_schema(Workflow, config)

    case apply(repo, :get, [schema, workflow_id, config]) do
      nil ->
        {:error, :workflow_not_found}

      workflow ->
        {:ok, workflow}
    end
  end

  def delete_workflow(config, workflow_id) do
    schema = get_schema(Workflow, config)

    workflow = struct(schema, id: workflow_id)

    {:ok, _changes} =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:delete, workflow)
      |> repo_transaction(config)

    :ok
  end
end
