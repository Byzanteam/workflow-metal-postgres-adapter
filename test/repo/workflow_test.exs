defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.WorkflowTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Workflow

  test "create workflows with places transitions and arcs" do
    assert {:ok, workflow} =
             Workflow.insert_workflow(
               @config,
               @workflow_schema,
               @workflow_associations_params
             )

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

  test "return already_exists" do
    assert {:ok, _workflow} =
             Workflow.insert_workflow(
               @config,
               @workflow_schema,
               @workflow_associations_params
             )

    assert {:error, :already_exists} =
             Workflow.insert_workflow(
               @config,
               @workflow_schema,
               @workflow_associations_params
             )
  end

  describe "fetch workflow/2" do
    setup :insert_workflow_schema

    test "success", %{workflow: workflow} do
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
    setup :insert_workflow_schema

    test "ok", %{workflow: workflow} do
      assert :ok = Workflow.delete_workflow(@config, workflow.id)

      assert {:error, :workflow_not_found} = Workflow.fetch_workflow(@config, workflow.id)
    end
  end
end
