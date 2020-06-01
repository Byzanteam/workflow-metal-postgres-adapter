defmodule WorkflowMetalPostgresAdapter.Query.Workflow do
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Schema.{Workflow, Place, Transition, Arc}

  alias Ecto.Multi

  def create_workflow(adapter_meta, workflow_params) do
    repo = repo(adapter_meta)

    workflow_id = Ecto.UUID.generate()
    inserted_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    %{
      places: places,
      transitions: transitions,
      arcs: arcs
    } = workflow_params

    places_rid_to_uuids =
      for place <- places, into: %{} do
        {place.rid, Ecto.UUID.generate()}
      end

    transition_rid_to_uuids =
      for transition <- transitions, into: %{} do
        {transition.rid, Ecto.UUID.generate()}
      end

    place_params =
      Enum.map(places, fn place ->
        params = if is_struct(place), do: Map.from_struct(place), else: place

        params
        |> Map.merge(%{
          id: places_rid_to_uuids[params.rid],
          workflow_id: workflow_id,
          inserted_at: inserted_at
        })
        |> Map.delete(:rid)
      end)

    transition_params =
      Enum.map(transitions, fn transition ->
        params = if is_struct(transition), do: Map.from_struct(transition), else: transition

        params
        |> Map.merge(%{
          id: transition_rid_to_uuids[params.rid],
          workflow_id: workflow_id,
          executor: params.executor,
          inserted_at: inserted_at
        })
        |> Map.delete(:rid)
      end)

    arc_params =
      Enum.map(arcs, fn arc ->
        params = if is_struct(arc), do: Map.from_struct(arc), else: arc

        params
        |> Map.merge(%{
          id: Ecto.UUID.generate(),
          place_id: places_rid_to_uuids[params.place_rid],
          transition_id: transition_rid_to_uuids[params.transition_rid],
          workflow_id: workflow_id,
          inserted_at: inserted_at
        })
        |> Map.drop([:place_rid, :transition_rid])
      end)

    Multi.new()
    |> Multi.insert(:workflow, %Workflow{id: workflow_id, state: :active})
    |> Multi.insert_all(:places, Place, place_params)
    |> Multi.insert_all(:transitions, Transition, transition_params)
    |> Multi.insert_all(:arcs, Arc, arc_params)
    |> repo.transaction()
    |> case do
      {:ok, %{workflow: workflow}} -> {:ok, workflow}
      error -> error
    end
  end

  def fetch_workflow(adapter_meta, workflow_id) do
    repo = repo(adapter_meta)

    case repo.get(Workflow, workflow_id) do
      nil ->
        {:error, :workflow_not_found}

      workflow ->
        {:ok, repo.preload(workflow, [:places, :transitions, :arcs])}
    end
  end

  def delete_workflow(adapter_meta, workflow_id) do
    repo = repo(adapter_meta)
    query = from w in Workflow, where: w.id == ^workflow_id
    repo.delete_all(query)
    :ok
  end
end
