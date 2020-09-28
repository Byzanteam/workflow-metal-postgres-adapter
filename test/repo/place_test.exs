defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.PlaceTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Place

  describe "fetch_edge_places/2" do
    setup :insert_workflow_schema

    test "success", %{
      workflow: workflow,
      associations_params: associations_params
    } do
      %{
        places: [start_place, _, _, _, end_place]
      } = associations_params

      assert {:ok, {start_schema_place, end_schema_place}} =
               Place.fetch_edge_places(@config, workflow.id)

      assert start_schema_place.id === start_place.id
      assert end_schema_place.id === end_place.id
    end
  end

  describe "fetch_places/3" do
    setup :insert_workflow_schema

    test "success", %{associations_params: associations_params} do
      %{
        transitions: [init_transition | _],
        places: [start_place, yellow_place | _]
      } = associations_params

      assert {:ok, [place]} = Place.fetch_places(@config, init_transition.id, :in)
      assert place.id === start_place.id

      assert {:ok, [place]} = Place.fetch_places(@config, init_transition.id, :out)
      assert place.id === yellow_place.id
    end
  end
end
