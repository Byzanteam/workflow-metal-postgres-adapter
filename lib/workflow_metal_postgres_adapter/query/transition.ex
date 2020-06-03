defmodule WorkflowMetalPostgresAdapter.Query.Transition do
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Schema.{Transition, Arc}
  alias WorkflowMetalPostgresAdapter.Query.Place

  def fetch_transition(adapter_meta, transition_id) do
    repo = repo(adapter_meta)

    case repo.get(Transition, transition_id, prefix: repo_schema()) do
      nil ->
        {:error, :transition_not_found}

      transition ->
        {:ok, transition}
    end
  end

  def fetch_transitions(adapter_meta, place_id, arc_direction) do
    with {:ok, place} <- Place.fetch_place(adapter_meta, place_id) do
      query =
        from a in Arc,
          where: a.place_id == ^place_id,
          where: a.direction == ^arc_direction,
          where: a.workflow_id == ^place.workflow_id,
          select: a.transition_id

      repo = repo(adapter_meta)

      case repo.all(query, prefix: repo_schema()) do
        [] ->
          {:ok, []}

        transition_ids ->
          transition_query = from t in Transition, where: t.id in ^transition_ids

          {:ok, repo.all(transition_query, prefix: repo_schema())}
      end
    end
  end
end
