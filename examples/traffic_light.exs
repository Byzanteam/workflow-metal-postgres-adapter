alias WorkflowMetal.Storage.Schema

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

TestStorage.Repo.start_link()

defmodule TrafficLight do
  @moduledoc false

  defmodule WorkflowStorage do
    use WorkflowMetal.Storage.Adapters.Postgres,
      repo: TestStorage.Repo,
      schema: TestStorage.Schema
  end

  defmodule Workflow do
    use WorkflowMetal.Application,
      registry: WorkflowMetal.Registration.LocalRegistry,
      storage: TrafficLight.WorkflowStorage
  end

  defmodule Init do
    @moduledoc false

    use WorkflowMetal.Executor, application: Workflow

    alias WorkflowMetal.Storage.Schema

    @impl WorkflowMetal.Executor
    def execute(%Schema.Workitem{} = workitem, _options) do
      {:ok, _tokens} = preexecute(workitem)

      IO.puts("\n#{TrafficLight.now()} the light is on.")

      {:completed, %{"state" => "inited"}}
    end
  end

  defmodule Y2R do
    @moduledoc false

    use WorkflowMetal.Executor, application: Workflow

    alias WorkflowMetal.Storage.Schema

    @impl WorkflowMetal.Executor
    def execute(%Schema.Workitem{} = workitem, options) do
      IO.puts("\n#{TrafficLight.now()} the light is about to turning red in 1s.")

      Task.start(__MODULE__, :run, [workitem, options])
      :started
    end

    def run(%Schema.Workitem{} = workitem, _options) do
      Process.sleep(1000)

      {:ok, _tokens} = preexecute(workitem)

      complete_workitem(workitem, %{"state" => "turn_red"})

      TrafficLight.log_light(:red)
    end
  end

  defmodule R2G do
    @moduledoc false

    use WorkflowMetal.Executor, application: Workflow

    alias WorkflowMetal.Storage.Schema

    @impl WorkflowMetal.Executor
    def execute(%Schema.Workitem{} = workitem, options) do
      IO.puts("\n#{TrafficLight.now()} the light is about to turning green in 5s.")

      Task.start(__MODULE__, :run, [workitem, options])
      :started
    end

    def run(%Schema.Workitem{} = workitem, _options) do
      Process.sleep(5000)

      case preexecute(workitem) do
        {:ok, _tokens} ->
          complete_workitem(workitem, %{"state" => "turn_green"})

          TrafficLight.log_light(:green)

        _ ->
          abandon_workitem(workitem)
      end
    end
  end

  defmodule G2Y do
    @moduledoc false

    use WorkflowMetal.Executor, application: Workflow

    alias WorkflowMetal.Storage.Schema

    @impl WorkflowMetal.Executor
    def execute(%Schema.Workitem{} = workitem, options) do
      IO.puts("\n#{TrafficLight.now()} the light is about to turning yellow in 4s.")

      Task.start(__MODULE__, :run, [workitem, options])
      :started
    end

    def run(%Schema.Workitem{} = workitem, _options) do
      Process.sleep(4000)

      {:ok, _tokens} = preexecute(workitem)

      complete_workitem(workitem, %{"state" => "turn_yellow"})

      TrafficLight.log_light(:yellow)
    end
  end

  defmodule WillEnd do
    @moduledoc false

    use WorkflowMetal.Executor, application: Workflow

    alias WorkflowMetal.Storage.Schema

    @impl WorkflowMetal.Executor
    def execute(%Schema.Workitem{} = workitem, _options) do
      # 50% chance
      if :rand.uniform(10) <= 5 do
        case preexecute(workitem) do
          {:ok, _tokens} ->
            IO.puts("\n#{TrafficLight.now()} the light is off.")

            {:completed, %{"state" => "ended"}}

          _ ->
            :abandoned
        end
      else
        :abandoned
      end
    end
  end

  def now do
    DateTime.utc_now() |> DateTime.to_string()
  end

  def log_light(color) do
    IO.puts([
      "\n",
      now(),
      " the light is ",
      apply(IO.ANSI, color, []),
      to_string(color),
      IO.ANSI.reset(),
      "."
    ])
  end
end

{:ok, _pid} = TrafficLight.Workflow.start_link()

%{id: workflow_id} =
  workflow_schema = %Schema.Workflow{
    id: Ecto.UUID.generate(),
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

associations_params = %{
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

config = [
  repo: TestStorage.Repo,
  schema: TestStorage.Schema
]

{:ok, traffic_light_workflow} =
  TrafficLight.WorkflowStorage.insert_workflow(
    config,
    workflow_schema,
    associations_params
  )

{:ok, workflow_case} =
  TrafficLight.WorkflowStorage.insert_case(config, %Schema.Case{
    id: Ecto.UUID.generate(),
    state: :created,
    workflow_id: traffic_light_workflow.id
  })

TrafficLight.Workflow.open_case(workflow_case.id)
