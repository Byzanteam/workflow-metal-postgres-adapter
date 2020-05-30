defmodule WorkflowMetalPostgresAdapter.Query.TransitionTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Transition, Workflow, Place}

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
    %{workflow: workflow, adapter_meta: @adapter_meta}
  end

  describe "fetch_transitions/2" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, start_place, end_place} = Place.fetch_edge_places(adapter_meta, workflow.id)
      {:ok, %{transitions: [transition]}} = Workflow.fetch_workflow(adapter_meta, workflow.id)
      assert {:ok, []} = Transition.fetch_transitions(adapter_meta, start_place.id, :in)
      assert {:ok, [fetch_transition]} = Transition.fetch_transitions(adapter_meta, start_place.id, :out)
      assert fetch_transition.id == transition.id

      assert {:ok, []} = Transition.fetch_transitions(adapter_meta, end_place.id, :out)
      assert {:ok, [fetch_transition]} = Transition.fetch_transitions(adapter_meta, end_place.id, :in)
      assert fetch_transition.id == transition.id
    end
  end


  describe "fetch_transition/2" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, %{transitions: [transition]}} = Workflow.fetch_workflow(adapter_meta, workflow.id)
      assert {:ok, new_transition} = Transition.fetch_transition(adapter_meta, transition.id)
      assert new_transition.id == transition.id
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :transition_not_found} = Transition.fetch_transition(adapter_meta, Ecto.UUID.generate())
    end
  end
end
