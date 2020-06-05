defmodule WorkflowMetalPostgresAdapter.Query.ArcTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Arc, Workflow, Place}

  @params %{
    places: [
      %{rid: :start, type: :start},
      %{rid: :end, type: :end}
    ],
    transitions: [
      %{rid: :init, executor: TrafficLight.Init}
    ],
    arcs: [
      %{place_rid: :start, transition_rid: :init, direction: :out},
      %{place_rid: :end, transition_rid: :init, direction: :in}
    ]
  }

  setup do
    {:ok, workflow} = Workflow.create_workflow(@adapter_meta, @params)
    workflow = Workflow.preload(@adapter_meta, workflow.id)
    %{workflow: workflow, adapter_meta: @adapter_meta}
  end

  describe "fetch_arcs/3" do
    test "transition", %{workflow: workflow, adapter_meta: adapter_meta} do
      %{transitions: [transition]} = workflow
      {:ok, {start_place, end_place}} = Place.fetch_edge_places(adapter_meta, workflow.id)
      assert {:ok, [arc]} = Arc.fetch_arcs(adapter_meta, {:transition, transition.id}, :in)
      assert arc.direction == :out
      assert arc.place_id == start_place.id
      assert {:ok, [arc]} = Arc.fetch_arcs(adapter_meta, {:transition, transition.id}, :out)
      assert arc.direction == :in
      assert arc.place_id == end_place.id
    end

    test "place", %{workflow: workflow, adapter_meta: adapter_meta} do
      %{transitions: [transition]} = workflow
      {:ok, {start_place, end_place}} = Place.fetch_edge_places(adapter_meta, workflow.id)
      assert {:ok, []} = Arc.fetch_arcs(adapter_meta, {:place, start_place.id}, :in)
      assert {:ok, [arc]} = Arc.fetch_arcs(adapter_meta, {:place, start_place.id}, :out)
      assert arc.place_id == start_place.id
      assert arc.transition_id == transition.id

      assert {:ok, []} = Arc.fetch_arcs(adapter_meta, {:place, end_place.id}, :out)
      assert {:ok, [arc]} = Arc.fetch_arcs(adapter_meta, {:place, end_place.id}, :in)
      assert arc.place_id == end_place.id
      assert arc.transition_id == transition.id
    end
  end
end
