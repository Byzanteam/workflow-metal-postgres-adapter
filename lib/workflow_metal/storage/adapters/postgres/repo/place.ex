defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Place do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def fetch_edge_places(config, workflow_id) do
    schema = get_schema(Place, config)

    start_place = repo_get_by(schema, [workflow_id: workflow_id, type: :start], config)
    end_place = repo_get_by(schema, [workflow_id: workflow_id, type: :end], config)

    {:ok, {start_place, end_place}}
  end

  def fetch_places(config, transition_id, arc_direction) do
    import Ecto.Query

    place_schema = get_schema(Place, config)
    arc_schema = get_schema(Arc, config)

    direction = reversed_arc_direction(arc_direction)

    places =
      arc_schema
      |> where(transition_id: ^transition_id, direction: ^direction)
      |> join(:inner, [a], p in ^place_schema, on: a.place_id == p.id)
      |> select([a, p], p)
      |> repo_all(config)

    {:ok, places}
  end

  defp reversed_arc_direction(:in), do: :out
  defp reversed_arc_direction(:out), do: :in
end
