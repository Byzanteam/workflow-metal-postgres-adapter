defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.Transition do
  @moduledoc false

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Place

  use WorkflowMetal.Storage.Adapters.Postgres.Repo

  def fetch_transition(config, transition_id) do
    schema = get_schema(Transition, config)

    case repo_get_by(schema, [id: transition_id], config) do
      nil ->
        {:error, :transition_not_found}

      transition ->
        {:ok, transition}
    end
  end

  def fetch_transitions(config, place_id, arc_direction) do
    import Ecto.Query

    transition_schema = get_schema(Transition, config)
    arc_schema = get_schema(Arc, config)

    transitions =
      arc_schema
      |> where(place_id: ^place_id, direction: ^arc_direction)
      |> join(:inner, [a], t in ^transition_schema, on: a.transition_id == t.id)
      |> select([a, t], t)
      |> repo_all(config)

    {:ok, transitions}
  end
end
