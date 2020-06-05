defmodule WorkflowMetalPostgresAdapter.Query.CaseTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Case, Workflow}

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
    %{workflow: workflow, adapter_meta: @adapter_meta}
  end

  describe "create_case/2" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      assert {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})
      assert workflow_case.state == :created
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :workflow_not_found} =
               Case.create_case(adapter_meta, %{workflow_id: Ecto.UUID.generate()})
    end
  end

  describe "fetch_case/2" do
    test "success", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})
      assert {:ok, fetch_case} = Case.fetch_case(adapter_meta, workflow_case.id)
      assert fetch_case.id == workflow_case.id
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :case_not_found} = Case.fetch_case(adapter_meta, Ecto.UUID.generate())
    end
  end

  describe "update_case/2" do
    test "active_case", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})
      assert {:ok, update_case} = Case.update_case(adapter_meta, workflow_case.id, :active)
      assert update_case.state == :active
    end

    test "finish_case", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})
      {:ok, _update_case} = Case.update_case(adapter_meta, workflow_case.id, :active)
      assert {:ok, update_case} = Case.update_case(adapter_meta, workflow_case.id, :finished)
      assert update_case.state == :finished
    end

    test "cancel_case", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})
      {:ok, _update_case} = Case.update_case(adapter_meta, workflow_case.id, :active)
      assert {:ok, update_case} = Case.update_case(adapter_meta, workflow_case.id, :canceled)
      assert update_case.state == :canceled

      {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})
      assert {:ok, update_case} = Case.update_case(adapter_meta, workflow_case.id, :canceled)
      assert update_case.state == :canceled
    end

    test "invalid updated", %{workflow: workflow, adapter_meta: adapter_meta} do
      {:ok, workflow_case} = Case.create_case(adapter_meta, %{workflow_id: workflow.id})

      assert {:error, :case_not_available} =
               Case.update_case(adapter_meta, workflow_case.id, :finished)

      {:ok, workflow_case} = Case.update_case(adapter_meta, workflow_case.id, :canceled)

      assert {:error, :case_not_available} =
               Case.update_case(adapter_meta, workflow_case.id, :finished)

      assert {:error, :case_not_available} =
               Case.update_case(adapter_meta, workflow_case.id, :active)
    end
  end
end
