defmodule WorkflowMetal.Storage.Adapters.Postgres.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias WorkflowMetal.Storage.Schema

  using do
    quote do
      alias TestStorage.Repo

      @config [
        repo: TestStorage.Repo,
        schema: TestStorage.Schema
      ]

      @workflow_schema unquote(__MODULE__).build_workflow_schema()
      @workflow_associations_params unquote(__MODULE__).build_associations_params(
                                      @workflow_schema
                                    )

      defp insert_workflow_schema(_context) do
        alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Workflow

        workflow_schema = unquote(__MODULE__).build_workflow_schema()
        associations_params = unquote(__MODULE__).build_associations_params(workflow_schema)

        {:ok, workflow} =
          Workflow.insert_workflow(
            @config,
            workflow_schema,
            associations_params
          )

        [workflow: workflow, associations_params: associations_params]
      end
    end
  end

  setup tags do
    alias TestStorage.Repo
    alias Ecto.Adapters.SQL.Sandbox

    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end

  # Traffic light
  #
  # +------+                    +-----+                      +----------+
  # | init +---->(yellow)+----->+ y2r +------>(red)+-------->+ will_end |
  # +---+--+         ^          +-----+         +            +-----+----+
  #     ^            |                          |                  |
  #     |            |                          v                  |
  #     +         +--+--+                    +--+--+               v
  #  (start)      | g2y +<----+(green)<------+ r2g |             (end)
  #               +-----+                    +-----+

  def build_workflow_schema do
    %Schema.Workflow{
      id: Ecto.UUID.generate(),
      state: :active
    }
  end

  def build_associations_params(workflow_schema) do
    %{id: workflow_id} = workflow_schema

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

    %{
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
  end
end
