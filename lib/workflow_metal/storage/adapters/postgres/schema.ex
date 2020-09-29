defmodule WorkflowMetal.Storage.Adapters.Postgres.Schema do
  @moduledoc """
  Define storage schema.

  ```elixir
  defmodule TestStorage.Schema do
    @moduledoc false

    import WorkflowMetal.Storage.Adapters.Postgres.Schema

    workflow_schema "workflows" do
      timestamps()
    end

    place_schema "places" do
      timestamps()
    end

    transition_schema "transitions",
      join_type: TestStorage.TransitionTypes.JoinTypeEnum,
      split_type: TestStorage.TransitionTypes.SplitTypeEnum do
      timestamps()
    end

    arc_schema "arcs" do
      timestamps()
    end

    case_schema "cases" do
      timestamps()
    end

    token_schema "tokens" do
      timestamps()
    end

    task_schema "tasks" do
      timestamps()
    end

    workitem_schema "workitems" do
      timestamps()
    end
  end
  ```
  """

  defmacro workflow_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Workflow do
        @moduledoc """
        Workflow for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :state, Ecto.Enum, values: [:active, :discarded]

          field :metadata, :map

          has_many :places, unquote(schema).Place
          has_many :transitions, unquote(schema).Transition
          has_many :arcs, unquote(schema).Arc

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Workflow{} = workflow) do
            %WorkflowMetal.Storage.Schema.Workflow{
              id: workflow.id,
              state: workflow.state,
              metadata: workflow.metadata
            }
          end
        end
      end
    end
  end

  defmacro place_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Place do
        @moduledoc """
        Place for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :type, Ecto.Enum, values: [:start, :normal, :end]
          field :metadata, :map

          belongs_to :workflow, unquote(schema).Workflow

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Place{} = place) do
            %WorkflowMetal.Storage.Schema.Place{
              id: place.id,
              workflow_id: place.workflow_id,
              type: place.type,
              metadata: place.metadata
            }
          end
        end
      end
    end
  end

  defmacro transition_schema(source, options, do: block) do
    join_type = Keyword.fetch!(options, :join_type)
    split_type = Keyword.fetch!(options, :split_type)

    schema = __CALLER__.module

    quote do
      defmodule Transition do
        @moduledoc """
        Transition for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :join_type, unquote(join_type)
          field :split_type, unquote(split_type)
          field :executor, WorkflowMetal.Storage.Adapters.Postgres.Schema.ExecutorType
          field :executor_params, :map
          field :metadata, :map

          belongs_to :workflow, unquote(schema).Workflow

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Transition{} = transition) do
            %WorkflowMetal.Storage.Schema.Transition{
              id: transition.id,
              workflow_id: transition.workflow_id,
              join_type: transition.join_type,
              split_type: transition.split_type,
              executor: transition.executor,
              executor_params: transition.executor_params,
              metadata: transition.metadata
            }
          end
        end
      end
    end
  end

  defmacro arc_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Arc do
        @moduledoc """
        Arc for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :direction, Ecto.Enum, values: [:in, :out]
          field :metadata, :map

          belongs_to :workflow, unquote(schema).Workflow
          belongs_to :place, unquote(schema).Place
          belongs_to :transition, unquote(schema).Transition

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Arc{} = arc) do
            %WorkflowMetal.Storage.Schema.Arc{
              id: arc.id,
              workflow_id: arc.workflow_id,
              transition_id: arc.transition_id,
              place_id: arc.place_id,
              direction: arc.direction,
              metadata: arc.metadata
            }
          end
        end
      end
    end
  end

  defmacro case_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Case do
        @moduledoc """
        Case for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :state, Ecto.Enum, values: [:created, :active, :canceled, :finished]

          belongs_to :workflow, unquote(schema).Workflow

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Case{} = workflow_case) do
            %WorkflowMetal.Storage.Schema.Case{
              id: workflow_case.id,
              workflow_id: workflow_case.workflow_id,
              state: workflow_case.state
            }
          end
        end
      end
    end
  end

  defmacro token_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Token do
        @moduledoc """
        Token for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :state, Ecto.Enum, values: [:free, :locked, :consumed]
          field :payload, :map

          field :place_id, Ecto.UUID
          field :case_id, Ecto.UUID
          field :produced_by_task_id, Ecto.UUID
          field :locked_by_task_id, Ecto.UUID
          field :consumed_by_task_id, Ecto.UUID

          belongs_to :workflow, unquote(schema).Workflow

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Token{} = token) do
            %WorkflowMetal.Storage.Schema.Token{
              id: token.id,
              workflow_id: token.workflow_id,
              case_id: token.case_id,
              place_id: token.place_id,
              produced_by_task_id: token.produced_by_task_id,
              locked_by_task_id: token.locked_by_task_id,
              consumed_by_task_id: token.consumed_by_task_id,
              payload: token.payload,
              state: token.state
            }
          end
        end
      end
    end
  end

  defmacro task_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Task do
        @moduledoc """
        Task for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :state, Ecto.Enum,
            values: [:started, :allocated, :executing, :completed, :abandoned]

          field :transition_id, Ecto.UUID
          field :case_id, Ecto.UUID
          field :token_payload, :map

          belongs_to :workflow, unquote(schema).Workflow

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Task{} = task) do
            %WorkflowMetal.Storage.Schema.Task{
              id: task.id,
              workflow_id: task.workflow_id,
              transition_id: task.transition_id,
              case_id: task.case_id,
              state: task.state,
              token_payload: task.token_payload
            }
          end
        end
      end
    end
  end

  defmacro workitem_schema(source, do: block) do
    schema = __CALLER__.module

    quote do
      defmodule Workitem do
        @moduledoc """
        Workitem for #{inspect(unquote(schema))}.
        """

        unquote(schema_attributes())

        schema unquote(source) do
          field :state, Ecto.Enum, values: [:created, :started, :completed, :abandoned]
          field :output, :map

          field :transition_id, Ecto.UUID
          field :case_id, Ecto.UUID
          field :task_id, Ecto.UUID

          belongs_to :workflow, unquote(schema).Workflow

          unquote(block)
        end

        defimpl WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
          def transform(%unquote(schema).Workitem{} = workitem) do
            %WorkflowMetal.Storage.Schema.Workitem{
              id: workitem.id,
              workflow_id: workitem.workflow_id,
              transition_id: workitem.transition_id,
              case_id: workitem.case_id,
              task_id: workitem.task_id,
              output: workitem.output,
              state: workitem.state
            }
          end
        end
      end
    end
  end

  defp schema_attributes do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: false}
      @foreign_key_type :binary_id
    end
  end
end
