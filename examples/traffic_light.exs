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

WorkflowMetalPostgresAdapter.Repo.start_link()

defmodule TrafficLight do
  @moduledoc false

  defmodule TransitionTypes do
    defmodule SplitTypeEnum do
      use EctoEnum,
        none: 0,
        and: 1
    end

    defmodule JoinTypeEnum do
      use EctoEnum,
        none: 0,
        and: 1
    end
  end

  defmodule Workflow do
    use WorkflowMetal.Application,
      registry: WorkflowMetal.Registration.LocalRegistry,
      storage: {
        WorkflowMetalPostgresAdapter,
        repo: WorkflowMetalPostgresAdapter.Repo,
        enum_types: [
          transition: [
            split_type: TransitionTypes.SplitTypeEnum,
            join_type: TransitionTypes.JoinTypeEnum
          ]
        ]
      }
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

{:ok, traffic_light_workflow} =
  WorkflowMetal.Storage.create_workflow(
    TrafficLight.Workflow,
    %Schema.Workflow.Params{
      places: [
        %Schema.Place.Params{id: :start, type: :start},
        %Schema.Place.Params{id: :yellow, type: :normal},
        %Schema.Place.Params{id: :red, type: :normal},
        %Schema.Place.Params{id: :green, type: :normal},
        %Schema.Place.Params{id: :end, type: :end}
      ],
      transitions: [
        %Schema.Transition.Params{id: :init, executor: TrafficLight.Init, split_type: :none, join_type: :none},
        %Schema.Transition.Params{id: :y2r, executor: TrafficLight.Y2R, split_type: :none, join_type: :none},
        %Schema.Transition.Params{id: :r2g, executor: TrafficLight.R2G, split_type: :none, join_type: :none},
        %Schema.Transition.Params{id: :g2y, executor: TrafficLight.G2Y, split_type: :none, join_type: :none},
        %Schema.Transition.Params{id: :will_end, executor: TrafficLight.WillEnd, split_type: :none, join_type: :none}
      ],
      arcs: [
        %Schema.Arc.Params{place_id: :start, transition_id: :init, direction: :out},
        %Schema.Arc.Params{place_id: :yellow, transition_id: :init, direction: :in},
        %Schema.Arc.Params{place_id: :yellow, transition_id: :y2r, direction: :out},
        %Schema.Arc.Params{place_id: :yellow, transition_id: :g2y, direction: :in},
        %Schema.Arc.Params{place_id: :red, transition_id: :y2r, direction: :in},
        %Schema.Arc.Params{place_id: :red, transition_id: :will_end, direction: :out},
        %Schema.Arc.Params{place_id: :red, transition_id: :r2g, direction: :out},
        %Schema.Arc.Params{place_id: :green, transition_id: :r2g, direction: :in},
        %Schema.Arc.Params{place_id: :green, transition_id: :g2y, direction: :out},
        %Schema.Arc.Params{place_id: :end, transition_id: :will_end, direction: :in}
      ]
    }
  )

# Create a case
# ```elixir
# WorkflowMetal.Case.Supervisor.create_case TrafficLight, %Schema.Case.Params{workflow_id: traffic_light_workflow.id}
# ```
WorkflowMetal.Case.Supervisor.create_case(TrafficLight.Workflow, %Schema.Case.Params{
  workflow_id: traffic_light_workflow.id
})
