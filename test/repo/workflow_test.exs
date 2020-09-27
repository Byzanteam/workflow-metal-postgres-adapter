defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.WorkflowTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Workflow
  alias WorkflowMetal.Storage.Schema

  workflow_id = Ecto.UUID.generate()

  @schema %Schema.Workflow{
    id: workflow_id,
    state: :active
  }

  start_id = Ecto.UUID.generate()
  yellow_id = Ecto.UUID.generate()
  red_id = Ecto.UUID.generate()
  green_id = Ecto.UUID.generate()
  end_id = Ecto.UUID.generate()

  init_id = Ecto.UUID.generate()
  y2r_id = Ecto.UUID.generate()
  r2g_id = Ecto.UUID.generate()
  g2y_id = Ecto.UUID.generate()
  will_end_id = Ecto.UUID.generate()

  @association_schemas %{
    places: [
      %Schema.Place{id: start_id, type: :start, workflow_id: workflow_id},
      %Schema.Place{id: yellow_id, type: :normal, workflow_id: workflow_id},
      %Schema.Place{id: red_id, type: :normal, workflow_id: workflow_id},
      %Schema.Place{id: green_id, type: :normal, workflow_id: workflow_id},
      %Schema.Place{id: end_id, type: :end, workflow_id: workflow_id}
    ],
    transitions: [
      %Schema.Transition{
        id: init_id,
        executor: TrafficLight.Init,
        split_type: :none,
        join_type: :none,
        workflow_id: workflow_id
      },
      %Schema.Transition{
        id: y2r_id,
        executor: TrafficLight.Y2R,
        split_type: :none,
        join_type: :none,
        workflow_id: workflow_id
      },
      %Schema.Transition{
        id: r2g_id,
        executor: TrafficLight.R2G,
        split_type: :none,
        join_type: :none,
        workflow_id: workflow_id
      },
      %Schema.Transition{
        id: g2y_id,
        executor: TrafficLight.G2Y,
        split_type: :none,
        join_type: :none,
        workflow_id: workflow_id
      },
      %Schema.Transition{
        id: will_end_id,
        executor: TrafficLight.WillEnd,
        split_type: :none,
        join_type: :none,
        workflow_id: workflow_id
      }
    ],
    arcs: [
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: start_id,
        transition_id: init_id,
        direction: :out,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: yellow_id,
        transition_id: init_id,
        direction: :in,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: yellow_id,
        transition_id: y2r_id,
        direction: :out,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: yellow_id,
        transition_id: g2y_id,
        direction: :in,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: red_id,
        transition_id: y2r_id,
        direction: :in,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: red_id,
        transition_id: will_end_id,
        direction: :out,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: red_id,
        transition_id: r2g_id,
        direction: :out,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: green_id,
        transition_id: r2g_id,
        direction: :in,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: green_id,
        transition_id: g2y_id,
        direction: :out,
        workflow_id: workflow_id
      },
      %Schema.Arc{
        id: Ecto.UUID.generate(),
        place_id: end_id,
        transition_id: will_end_id,
        direction: :in,
        workflow_id: workflow_id
      }
    ]
  }

  test "create workflows with places transitions and arcs" do
    assert {:ok, workflow} = Workflow.insert_workflow(@config, @schema, @association_schemas)

    %{
      arcs: arcs,
      transitions: transitions,
      places: places
    } = Repo.preload(workflow, [:places, :transitions, :arcs])

    assert workflow.state == :active
    assert length(arcs) == 10
    assert length(transitions) == 5
    assert length(places) == 5
  end

  describe "fetch workflow/2" do
    test "success" do
      {:ok, workflow} = Workflow.insert_workflow(@config, @schema, @association_schemas)

      assert {:ok, workflow} = Workflow.fetch_workflow(@config, workflow.id)

      %{
        arcs: arcs,
        transitions: transitions,
        places: places
      } = Repo.preload(workflow, [:places, :transitions, :arcs])

      assert length(arcs) == 10
      assert length(transitions) == 5
      assert length(places) == 5
    end

    test "not found" do
      assert {:error, :workflow_not_found} =
               Workflow.fetch_workflow(@config, Ecto.UUID.generate())
    end
  end

  describe "delete workflow/2" do
    test "ok" do
      {:ok, workflow} = Workflow.insert_workflow(@config, @schema, @association_schemas)
      assert :ok = Workflow.delete_workflow(@config, workflow.id)

      assert {:error, :workflow_not_found} = Workflow.fetch_workflow(@config, workflow.id)
    end
  end
end
