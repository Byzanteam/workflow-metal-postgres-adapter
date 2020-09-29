defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.WorkitemTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.{Case, Task, Workitem}

  setup :insert_workflow_schema

  setup %{workflow: workflow, associations_params: associations_params} do
    {:ok, workflow_case} =
      Case.insert_case(
        @config,
        %Schema.Case{
          id: Ecto.UUID.generate(),
          state: :created,
          workflow_id: workflow.id
        }
      )

    %{transitions: [transition | _]} = associations_params

    {:ok, task} =
      Task.insert_task(@config, %Schema.Task{
        id: Ecto.UUID.generate(),
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :started
      })

    %{
      workflow: workflow,
      workflow_case: workflow_case,
      transition: transition,
      task: task
    }
  end

  describe "insert_workitem/2" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      transition: transition,
      task: task
    } do
      workitem_schema = %Schema.Workitem{
        id: Ecto.UUID.generate(),
        state: :started,
        transition_id: transition.id,
        task_id: task.id,
        case_id: workflow_case.id,
        workflow_id: workflow.id
      }

      assert {:ok, workitem} = Workitem.insert_workitem(@config, workitem_schema)
      assert workitem.state == :started
    end
  end

  describe "fetch_workitem/2" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      transition: transition,
      task: task
    } do
      workitem_schema = %Schema.Workitem{
        id: Ecto.UUID.generate(),
        state: :started,
        workflow_id: workflow.id,
        task_id: task.id,
        transition_id: transition.id,
        case_id: workflow_case.id
      }

      {:ok, workitem} = Workitem.insert_workitem(@config, workitem_schema)
      assert {:ok, fetch_workitem} = Workitem.fetch_workitem(@config, workitem.id)
      assert fetch_workitem.id == workitem.id
    end
  end

  describe "fetch_workitems/2" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      transition: transition,
      task: task
    } do
      workitem_schema_1 = %Schema.Workitem{
        id: Ecto.UUID.generate(),
        state: :started,
        workflow_id: workflow.id,
        task_id: task.id,
        transition_id: transition.id,
        case_id: workflow_case.id
      }

      workitem_schema_2 = %Schema.Workitem{
        id: Ecto.UUID.generate(),
        state: :started,
        workflow_id: workflow.id,
        task_id: task.id,
        transition_id: transition.id,
        case_id: workflow_case.id
      }

      {:ok, workitem_1} = Workitem.insert_workitem(@config, workitem_schema_1)
      {:ok, workitem_2} = Workitem.insert_workitem(@config, workitem_schema_2)
      assert {:ok, workitems} = Workitem.fetch_workitems(@config, task.id)
      assert length(workitems) == 2
      assert MapSet.new(workitems, & &1.id) === MapSet.new([workitem_1.id, workitem_2.id])
    end
  end

  describe "update_workitem/3" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      transition: transition,
      task: task
    } do
      workitem_schema = %Schema.Workitem{
        id: Ecto.UUID.generate(),
        state: :started,
        workflow_id: workflow.id,
        task_id: task.id,
        transition_id: transition.id,
        case_id: workflow_case.id
      }

      {:ok, workitem} = Workitem.insert_workitem(@config, workitem_schema)

      assert {:ok, workitem} = Workitem.update_workitem(@config, workitem.id, %{state: :started})
      assert workitem.state == :started

      assert {:ok, workitem} =
               Workitem.update_workitem(@config, workitem.id, %{
                 state: :completed,
                 output: %{"foo" => "bar"}
               })

      assert workitem.state == :completed
      assert workitem.output == %{"foo" => "bar"}
    end
  end
end
