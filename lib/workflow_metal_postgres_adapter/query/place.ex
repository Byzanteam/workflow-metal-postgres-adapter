defmodule WorkflowMetalPostgresAdapter.Query.Place do
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Schema.{Place, Arc}
  alias WorkflowMetalPostgresAdapter.Query.{Transition, Workflow}

  def fetch_edge_places(adapter_meta, workflow_id) do
    with {:ok, workflow} <- Workflow.fetch_workflow(adapter_meta, workflow_id) do
      repo = repo(adapter_meta)
      start_place = repo.get_by(Place, workflow_id: workflow.id, type: :start)
      end_place = repo.get_by(Place, workflow_id: workflow.id, type: :end)

      {:ok, {start_place, end_place}}
    end
  end

  def fetch_places(adapter_meta, transition_id, arc_direction) do
    with {:ok, transition} <- Transition.fetch_transition(adapter_meta, transition_id) do
      direction = reversed_arc_direction(arc_direction)

      arc_query =
        from a in Arc,
          where: a.transition_id == ^transition_id,
          where: a.workflow_id == ^transition.workflow_id,
          where: a.direction == ^direction,
          select: a.place_id

      repo = repo(adapter_meta)

      case repo.all(arc_query) do
        [] ->
          {:ok, []}

        place_ids ->
          place_query = from p in Place, where: p.id in ^place_ids

          {:ok, repo.all(place_query)}
      end
    end
  end

  def fetch_place(adapter_meta, place_id) do
    repo = repo(adapter_meta)

    case repo.get(Place, place_id) do
      nil -> {:error, :place_not_found}
      place -> {:ok, place}
    end
  end
end
