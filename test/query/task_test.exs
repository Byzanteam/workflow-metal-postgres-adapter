defmodule WorkflowMetalPostgresAdapter.Query.TaskTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Case, Workflow, Task}

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

    {:ok, workflow_case} = Case.create_case(@adapter_meta, %{workflow_id: workflow.id})

    %{
      workflow: workflow,
      adapter_meta: @adapter_meta,
      workflow_case: workflow_case
    }
  end

  describe "create_task/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case
    } do
      %{transitions: [transition]} = workflow

      task_params = %{
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :started
      }

      assert {:ok, task} = Task.create_task(adapter_meta, task_params)
      assert task.case_id == workflow_case.id
      assert task.transition_id == transition.id
      assert task.state == :started
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :workflow_not_found} =
               Case.create_case(adapter_meta, %{workflow_id: Ecto.UUID.generate()})
    end
  end

  describe "fetch_task/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case
    } do
      %{transitions: [transition]} = workflow

      task_params = %{
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :started
      }

      {:ok, task} = Task.create_task(adapter_meta, task_params)
      assert {:ok, fetch_task} = Task.fetch_task(adapter_meta, task.id)
      assert fetch_task.id == task.id
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :task_not_found} = Task.fetch_task(adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "fetch_tasks/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case
    } do
      %{transitions: [transition]} = workflow

      task_params_1 = %{
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :started
      }

      task_params_2 = %{
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :allocated
      }

      {:ok, task_1} = Task.create_task(adapter_meta, task_params_1)
      {:ok, task_2} = Task.create_task(adapter_meta, task_params_2)
      fetch_tasks_options = [states: [:started], transition_id: transition.id]

      assert {:ok, [^task_1]} =
               Task.fetch_tasks(adapter_meta, workflow_case.id, fetch_tasks_options)

      fetch_tasks_options = [states: [:allocated]]

      assert {:ok, [^task_2]} =
               Task.fetch_tasks(adapter_meta, workflow_case.id, fetch_tasks_options)
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :case_not_found} = Task.fetch_tasks(adapter_meta, Ecto.UUID.generate(), [])
    end
  end

  describe "update_tasks/2" do
    test "sequence update", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case
    } do
      %{transitions: [transition]} = workflow

      task_params = %{
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :started
      }

      {:ok, task} = Task.create_task(adapter_meta, task_params)
      assert {:ok, task} = Task.update_task(adapter_meta, task.id, :allocated)
      assert task.state == :allocated
      assert {:ok, task} = Task.update_task(adapter_meta, task.id, :executing)
      assert task.state == :executing
      assert {:ok, task} = Task.update_task(adapter_meta, task.id, {:completed, []})
      assert task.state == :completed
    end

    test "abandoned", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case
    } do
      %{transitions: [transition]} = workflow

      task_params = %{
        workflow_id: workflow.id,
        transition_id: transition.id,
        case_id: workflow_case.id,
        state: :started
      }

      {:ok, task_1} = Task.create_task(adapter_meta, task_params)
      {:ok, task_2} = Task.create_task(adapter_meta, %{task_params | state: :allocated})
      {:ok, task_3} = Task.create_task(adapter_meta, %{task_params | state: :executing})
      {:ok, task_4} = Task.create_task(adapter_meta, %{task_params | state: :completed})

      assert {:ok, task_1} = Task.update_task(adapter_meta, task_1.id, :abandoned)
      assert task_1.state == :abandoned
      assert {:ok, task_2} = Task.update_task(adapter_meta, task_2.id, :abandoned)
      assert task_2.state == :abandoned
      assert {:ok, task_3} = Task.update_task(adapter_meta, task_3.id, :abandoned)
      assert task_3.state == :abandoned
      assert {:error, :task_not_available} = Task.update_task(adapter_meta, task_4.id, :abandoned)
    end
  end
end
