defmodule WorkflowMetalPostgresAdapter.Query.WorkflowTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Schema.{Arc, Place, Transition}
  alias WorkflowMetalPostgresAdapter.Query.Workflow

  @params %{
    places: [
      %{rid: :start, type: :start},
      %{rid: :yellow, type: :normal},
      %{rid: :red, type: :normal},
      %{rid: :green, type: :normal},
      %{rid: :end, type: :end}
    ],
    transitions: [
      %{rid: :init, executor: TrafficLight.Init},
      %{rid: :y2r, executor: TrafficLight.Y2R},
      %{rid: :r2g, executor: TrafficLight.R2G},
      %{rid: :g2y, executor: TrafficLight.G2Y},
      %{rid: :will_end, executor: TrafficLight.WillEnd}
    ],
    arcs: [
      %{place_rid: :start, transition_rid: :init, direction: :out},
      %{place_rid: :yellow, transition_rid: :init, direction: :in},
      %{place_rid: :yellow, transition_rid: :y2r, direction: :out},
      %{place_rid: :yellow, transition_rid: :g2y, direction: :in},
      %{place_rid: :red, transition_rid: :y2r, direction: :in},
      %{place_rid: :red, transition_rid: :will_end, direction: :out},
      %{place_rid: :red, transition_rid: :r2g, direction: :out},
      %{place_rid: :green, transition_rid: :r2g, direction: :in},
      %{place_rid: :green, transition_rid: :g2y, direction: :out},
      %{place_rid: :end, transition_rid: :will_end, direction: :in}
    ]
  }

  test "create workflows with places transitions and arcs" do
    assert {:ok, workflow} = Workflow.create_workflow(WorkflowMetalPostgresAdapter, @params)

    arcs = Repo.all(Arc)
    transitions = Repo.all(Transition)
    places = Repo.all(Place)

    assert workflow.state == :active
    assert length(arcs) == 10
    assert length(transitions) == 5
    assert length(places) == 5
  end

  describe "fetch workflow/2" do
    test "success" do
      {:ok, workflow} = Workflow.create_workflow(WorkflowMetalPostgresAdapter, @params)

      assert {:ok, workflow} = Workflow.fetch_workflow(WorkflowMetalPostgresAdapter, workflow.id)

      %{places: places, transitions: transitions, arcs: arcs} = workflow

      assert length(arcs) == 10
      assert length(transitions) == 5
      assert length(places) == 5
    end

    test "not found" do
      assert {:error, :workflow_not_found} =
               Workflow.fetch_workflow(WorkflowMetalPostgresAdapter, Ecto.UUID.generate())
    end
  end

  describe "delete workflow/2" do
    test "ok" do
      {:ok, workflow} = Workflow.create_workflow(WorkflowMetalPostgresAdapter, @params)
      assert :ok = Workflow.delete_workflow(WorkflowMetalPostgresAdapter, workflow.id)

      assert {:error, :workflow_not_found} =
               Workflow.fetch_workflow(WorkflowMetalPostgresAdapter, workflow.id)
    end
  end
end
