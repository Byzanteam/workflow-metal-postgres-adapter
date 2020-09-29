defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Arc do
  @moduledoc false

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  import Ecto.Query

  def fetch_arcs(config, {:transition, transition_id}, arc_direction) do
    schema = get_schema(Arc, config)

    arcs =
      schema
      |> where(transition_id: ^transition_id, direction: ^reversed_arc_direction(arc_direction))
      |> select([a], a)
      |> repo_all(config)

    {:ok, arcs}
  end

  def fetch_arcs(config, {:place, place_id}, arc_direction) do
    schema = get_schema(Arc, config)

    arcs =
      schema
      |> where(place_id: ^place_id, direction: ^arc_direction)
      |> select([a], a)
      |> repo_all(config)

    {:ok, arcs}
  end

  defp reversed_arc_direction(:in), do: :out
  defp reversed_arc_direction(:out), do: :in
end
