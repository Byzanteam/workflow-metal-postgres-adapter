defmodule WorkflowMetalPostgresAdapter.Query.PlaceTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Place, Workflow}

  @params %{
    places: [
      %{id: :start, type: :start},
      %{id: :end, type: :end}
    ],
    transitions: [
      %{id: :init, executor: TrafficLight.Init, split_type: :none, join_type: :none}
    ],
    arcs: [
      %{place_id: :start, transition_id: :init, direction: :out},
      %{place_id: :end, transition_id: :init, direction: :in}
    ]
  }

  setup do
    {:ok, workflow} = Workflow.create_workflow(@adapter_meta, @params)
    %{workflow: workflow, adapter_meta: @adapter_meta}
  end

  describe "fetch_edge_places/2" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      assert {:ok, {start_place, end_place}} = Place.fetch_edge_places(adapter_meta, workflow.id)
      assert start_place.type == :start
      assert end_place.type == :end
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :workflow_not_found} =
               Place.fetch_edge_places(adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "fetch_places/3" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      %{transitions: [transition]} = Workflow.preload(adapter_meta, workflow.id)
      {:ok, {start_place, end_place}} = Place.fetch_edge_places(adapter_meta, workflow.id)
      assert {:ok, [fetch_start_place]} = Place.fetch_places(adapter_meta, transition.id, :in)
      assert fetch_start_place.id == start_place.id

      assert {:ok, [fetch_end_place]} = Place.fetch_places(adapter_meta, transition.id, :out)
      assert fetch_end_place.id == end_place.id
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :workflow_not_found} =
               Place.fetch_edge_places(adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "fetch_place/2" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      %{places: places} = Workflow.preload(adapter_meta, workflow.id)
      place = hd(places)
      assert {:ok, new_place} = Place.fetch_place(adapter_meta, place.id)
      assert new_place.id == place.id
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :place_not_found} = Place.fetch_place(adapter_meta, Ecto.UUID.generate())
    end
  end
end
