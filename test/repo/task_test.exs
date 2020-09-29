defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.TaskTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.{Case, Task}

  setup :insert_workflow_schema

  setup %{workflow: workflow} do
    {:ok, workflow_case} =
      Case.insert_case(
        @config,
        %Schema.Case{
          id: Ecto.UUID.generate(),
          state: :created,
          workflow_id: workflow.id
        }
      )

    %{
      workflow_case: workflow_case
    }
  end

  test "success", %{
    workflow: workflow,
    workflow_case: workflow_case,
    associations_params: associations_params
  } do
    %{transitions: [transition | _]} = associations_params

    task_schema = %Schema.Task{
      workflow_id: workflow.id,
      transition_id: transition.id,
      case_id: workflow_case.id,
      state: :started
    }

    # insert task
    assert {:ok, task} = Task.insert_task(@config, task_schema)

    # fetch task
    assert {:ok, task} = Task.fetch_task(@config, task.id)

    assert task.case_id == workflow_case.id
    assert task.transition_id == transition.id
    assert task.state == :started

    another_task_schema = %Schema.Task{
      workflow_id: workflow.id,
      transition_id: transition.id,
      case_id: workflow_case.id,
      state: :allocated
    }

    assert {:ok, another_task} = Task.insert_task(@config, another_task_schema)

    {:ok, [allocated_task]} =
      Task.fetch_tasks(
        @config,
        workflow_case.id,
        state: [:allocated]
      )

    assert allocated_task.id === another_task.id

    {:ok, tasks} = Task.fetch_tasks(@config, workflow_case.id, state: [:started, :allocated])

    assert MapSet.new(tasks, & &1.id) === MapSet.new([task.id, another_task.id])

    {:ok, tasks} =
      Task.fetch_tasks(@config, workflow_case.id,
        state: [:started, :allocated],
        transition_id: transition.id
      )

    assert MapSet.new(tasks, & &1.id) === MapSet.new([task.id, another_task.id])

    {:ok, [started_task]} =
      Task.fetch_tasks(
        @config,
        workflow_case.id,
        state: [:started],
        transition_id: transition.id
      )

    assert started_task.id === task.id

    # update task
    assert {:ok, updated_task} =
             Task.update_task(@config, task.id, %{
               state: :completed,
               token_payload: %{foo: "bar"}
             })

    assert {:ok, updated_task} = Task.fetch_task(@config, updated_task.id)
    assert updated_task.state === :completed
    assert updated_task.token_payload === %{"foo" => "bar"}
  end
end
