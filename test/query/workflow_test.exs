defmodule WorkflowMetalPostgresAdapter.Query.WorkflowTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.Workflow

  @params %{
    places: [
      %{id: :start, type: :start},
      %{id: :yellow, type: :normal},
      %{id: :red, type: :normal},
      %{id: :green, type: :normal},
      %{id: :end, type: :end}
    ],
    transitions: [
      %{id: :init, executor: TrafficLight.Init, split_type: :none, join_type: :none},
      %{id: :y2r, executor: TrafficLight.Y2R, split_type: :none, join_type: :none},
      %{id: :r2g, executor: TrafficLight.R2G, split_type: :none, join_type: :none},
      %{id: :g2y, executor: TrafficLight.G2Y, split_type: :none, join_type: :none},
      %{id: :will_end, executor: TrafficLight.WillEnd, split_type: :none, join_type: :none}
    ],
    arcs: [
      %{place_id: :start, transition_id: :init, direction: :out},
      %{place_id: :yellow, transition_id: :init, direction: :in},
      %{place_id: :yellow, transition_id: :y2r, direction: :out},
      %{place_id: :yellow, transition_id: :g2y, direction: :in},
      %{place_id: :red, transition_id: :y2r, direction: :in},
      %{place_id: :red, transition_id: :will_end, direction: :out},
      %{place_id: :red, transition_id: :r2g, direction: :out},
      %{place_id: :green, transition_id: :r2g, direction: :in},
      %{place_id: :green, transition_id: :g2y, direction: :out},
      %{place_id: :end, transition_id: :will_end, direction: :in}
    ]
  }

  test "create workflows with places transitions and arcs" do
    assert {:ok, workflow} = Workflow.create_workflow(@adapter_meta, @params)

    %{arcs: arcs, transitions: transitions, places: places} =
      Workflow.preload(@adapter_meta, workflow.id)

    assert workflow.state == :active
    assert length(arcs) == 10
    assert length(transitions) == 5
    assert length(places) == 5
  end

  describe "fetch workflow/2" do
    test "success" do
      {:ok, workflow} = Workflow.create_workflow(@adapter_meta, @params)

      assert {:ok, workflow} = Workflow.fetch_workflow(@adapter_meta, workflow.id)

      %{places: places, transitions: transitions, arcs: arcs} =
        Workflow.preload(@adapter_meta, workflow.id)

      assert length(arcs) == 10
      assert length(transitions) == 5
      assert length(places) == 5
    end

    test "not found" do
      assert {:error, :workflow_not_found} =
               Workflow.fetch_workflow(@adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "delete workflow/2" do
    test "ok" do
      {:ok, workflow} = Workflow.create_workflow(@adapter_meta, @params)
      assert :ok = Workflow.delete_workflow(@adapter_meta, workflow.id)

      assert {:error, :workflow_not_found} = Workflow.fetch_workflow(@adapter_meta, workflow.id)
    end
  end
end
