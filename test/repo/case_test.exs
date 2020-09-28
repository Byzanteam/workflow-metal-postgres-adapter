defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.CaseTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.Case

  describe "insert_case/2" do
    setup :insert_workflow_schema

    test "success", %{workflow: workflow} do
      case_id = Ecto.UUID.generate()

      case_schema = %Schema.Case{
        id: case_id,
        state: :created,
        workflow_id: workflow.id
      }

      assert {:ok, workflow_case} = Case.insert_case(@config, case_schema)
      assert workflow_case
    end
  end

  describe "fetch_case/2" do
    setup :insert_workflow_schema

    test "success", %{workflow: workflow} do
      case_id = Ecto.UUID.generate()

      case_schema = %Schema.Case{
        id: case_id,
        state: :created,
        workflow_id: workflow.id
      }

      assert {:ok, workflow_case} = Case.insert_case(@config, case_schema)
      assert workflow_case

      assert {:ok, workflow_case} = Case.fetch_case(@config, case_schema.id)
      assert workflow_case
    end
  end

  describe "update_case/3" do
    setup :insert_workflow_schema

    test "success", %{workflow: workflow} do
      case_id = Ecto.UUID.generate()

      case_schema = %Schema.Case{
        id: case_id,
        state: :created,
        workflow_id: workflow.id
      }

      assert {:ok, workflow_case} = Case.insert_case(@config, case_schema)
      assert workflow_case

      assert {:ok, workflow_case} = Case.update_case(@config, case_schema.id, %{state: :active})

      assert {:ok, workflow_case} = Case.fetch_case(@config, case_schema.id)
      assert workflow_case.state === :active
    end
  end
end
