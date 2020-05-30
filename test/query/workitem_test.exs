defmodule WorkflowMetalPostgresAdapter.Query.WorkitemTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Case, Workflow, Task, Workitem}

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
    {:ok, workflow} = Workflow.fetch_workflow(@adapter_meta, workflow.id)

    {:ok, workflow_case} =
      Case.create_case(@adapter_meta, %{workflow_id: workflow.id})

    transition = hd(workflow.transitions)

    task_params = %{
      workflow_id: workflow.id,
      transition_id: transition.id,
      case_id: workflow_case.id,
      state: :started
    }

    {:ok, task} = Task.create_task(@adapter_meta, task_params)

    %{
      workflow: workflow,
      adapter_meta: @adapter_meta,
      workflow_case: workflow_case,
      task: task
    }
  end

  describe "create_workitem/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      task: task
    } do
      workitem_params = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :started
      }

      assert {:ok, workitem} = Workitem.create_workitem(adapter_meta, workitem_params)
      assert workitem.state == :started
    end

    test "not found", %{
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      task: task
    } do
      workitem_params = %{
        workflow_id: Ecto.UUID.generate(),
        task_id: task.id,
        case_id: workflow_case.id,
        state: :started
      }

      assert {:error, :workflow_not_found} =
               Workitem.create_workitem(adapter_meta, workitem_params)
    end
  end

  describe "fetch_workitem/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      task: task
    } do
      workitem_params = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :started
      }

      {:ok, workitem} = Workitem.create_workitem(adapter_meta, workitem_params)
      assert {:ok, fetch_workitem} = Workitem.fetch_workitem(adapter_meta, workitem.id)
      assert fetch_workitem.id == workitem.id
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :workitem_not_found} =
               Workitem.fetch_workitem(adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "fetch_workitems/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      task: task
    } do
      workitem_params = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :started
      }

      {:ok, _workitem_1} = Workitem.create_workitem(adapter_meta, workitem_params)
      {:ok, _workitem_2} = Workitem.create_workitem(adapter_meta, workitem_params)
      assert {:ok, workitems} = Workitem.fetch_workitems(adapter_meta, task.id)
      assert length(workitems) == 2
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :task_not_found} =
               Workitem.fetch_workitems(adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "update_workitem/2" do
    test "sequence update", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      task: task
    } do
      workitem_params = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :created
      }

      {:ok, workitem} = Workitem.create_workitem(adapter_meta, workitem_params)
      assert {:ok, workitem} = Workitem.update_workitem(adapter_meta, workitem.id, :started)
      assert workitem.state == :started

      assert {:ok, workitem} =
               Workitem.update_workitem(adapter_meta, workitem.id, {:completed, %{}})

      assert workitem.state == :completed
    end

    test "abandoned", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      task: task
    } do
      workitem_params_1 = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :created
      }

      workitem_params_2 = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :started
      }

      workitem_params_3 = %{
        workflow_id: workflow.id,
        task_id: task.id,
        case_id: workflow_case.id,
        state: :completed
      }

      {:ok, workitem_1} = Workitem.create_workitem(adapter_meta, workitem_params_1)
      {:ok, workitem_2} = Workitem.create_workitem(adapter_meta, workitem_params_2)
      {:ok, workitem_3} = Workitem.create_workitem(adapter_meta, workitem_params_3)
      assert {:ok, workitem_1} = Workitem.update_workitem(adapter_meta, workitem_1.id, :abandoned)
      assert workitem_1.state == :abandoned
      assert {:ok, workitem_2} = Workitem.update_workitem(adapter_meta, workitem_2.id, :abandoned)
      assert workitem_2.state == :abandoned

      assert {:error, :workitem_not_available} =
               Workitem.update_workitem(adapter_meta, workitem_3.id, :abandoned)
    end
  end
end
