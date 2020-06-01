defmodule WorkflowMetalPostgresAdapter.Query.TokenTest do
  use WorkflowMetalPostgresAdapter.RepoCase

  alias WorkflowMetalPostgresAdapter.Query.{Case, Workflow, Task, Place, Token}

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

  @genesis_uuid "00000000-0000-0000-0000-000000000000"

  setup do
    {:ok, workflow} = Workflow.create_workflow(@adapter_meta, @params)
    workflow = Workflow.preload(@adapter_meta, workflow.id)

    {:ok, workflow_case} = Case.create_case(@adapter_meta, %{workflow_id: workflow.id})

    %{transitions: [transition]} = workflow

    task_params = %{
      workflow_id: workflow.id,
      transition_id: transition.id,
      case_id: workflow_case.id,
      state: :started
    }

    {:ok, task} = Task.create_task(@adapter_meta, task_params)

    {:ok, {start_place, _end_place}} = Place.fetch_edge_places(@adapter_meta, workflow.id)

    %{
      task: task,
      transition: transition,
      workflow: workflow,
      adapter_meta: @adapter_meta,
      workflow_case: workflow_case,
      place: start_place
    }
  end

  describe "issue_token/2" do
    test "genesis", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place
    } do
      token_params = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      assert {:ok, token} = Token.issue_token(adapter_meta, token_params)
      assert token.state == :free
      assert token.produced_by_task_id == @genesis_uuid
    end

    test "normal produced task", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_params = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: task.id
      }

      assert {:ok, token} = Token.issue_token(adapter_meta, token_params)
      assert token.state === :free
      assert token.produced_by_task_id === task.id
    end
  end

  describe "lock_tokens/3" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_params = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(adapter_meta, token_params)
      assert {:ok, [token]} = Token.lock_tokens(adapter_meta, [token.id], task.id)
      assert token.locked_by_task_id === task.id
      assert token.state === :locked

      assert {:error, :tokens_not_available} =
               Token.lock_tokens(adapter_meta, [token.id], task.id)
    end
  end

  describe "unlock_tokens/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_params = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(adapter_meta, token_params)
      {:ok, _tokens} = Token.lock_tokens(adapter_meta, [token.id], task.id)

      assert {:ok, [unlock_token]} = Token.unlock_tokens(adapter_meta, task.id)
      assert unlock_token.state === :free
      assert is_nil(unlock_token.locked_by_task_id)
      assert unlock_token.id === token.id
    end
  end

  describe "consume_tokens/2" do
    test "by task", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_params = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(adapter_meta, token_params)
      {:ok, _tokens} = Token.lock_tokens(adapter_meta, [token.id], task.id)

      assert {:ok, [token]} = Token.consume_tokens(adapter_meta, task.id)
      assert token.state == :consumed
      assert token.consumed_by_task_id == task.id
    end

    test "by termination case", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place
    } do
      token_params = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, _token} = Token.issue_token(adapter_meta, token_params)
      assert {:ok, [token]} = Token.consume_tokens(adapter_meta, {workflow_case.id, :termination})
      assert token.state == :consumed
      assert token.consumed_by_task_id == nil
    end
  end

  describe "fetch_tokens/2" do
    test "success", %{
      workflow: workflow,
      adapter_meta: adapter_meta,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_params_1 = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      token_params_2 = %{
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis,
        state: :locked
      }

      {:ok, token_1} = Token.issue_token(adapter_meta, token_params_1)
      {:ok, _token_2} = Token.issue_token(adapter_meta, token_params_2)
      {:ok, [token_1]} = Token.lock_tokens(adapter_meta, [token_1.id], task.id)

      fetch_tokens_options = [states: [:locked], locked_by_task_id: task.id]

      assert {:ok, [^token_1]} =
               Token.fetch_tokens(adapter_meta, workflow_case.id, fetch_tokens_options)

      fetch_tokens_options = [states: [:locked]]

      assert {:ok, tokens} =
               Token.fetch_tokens(adapter_meta, workflow_case.id, fetch_tokens_options)

      assert length(tokens) == 2
    end

    test "not found", %{adapter_meta: adapter_meta} do
      assert {:error, :case_not_found} =
               Token.fetch_tokens(adapter_meta, Ecto.UUID.generate(), [])
    end
  end
end
