defmodule WorkflowMetalPostgresAdapter.Query.Arc do
  @moduledoc false
  import WorkflowMetalPostgresAdapter.Query.Helper
  import Ecto.Query

  alias WorkflowMetalPostgresAdapter.Schema.Arc

  def fetch_arcs(adapter_meta, {:transition, transition_id}, arc_direction) do
    query =
      from a in Arc,
        where: a.transition_id == ^transition_id,
        where: a.direction == ^arc_direction

    repo = repo(adapter_meta)
    {:ok, repo.all(query)}
  end

  def fetch_arcs(adapter_meta, {:place, place_id}, arc_direction) do
    query = from a in Arc, where: a.place_id == ^place_id, where: a.direction == ^arc_direction
    repo = repo(adapter_meta)
    {:ok, repo.all(query)}
  end
end
