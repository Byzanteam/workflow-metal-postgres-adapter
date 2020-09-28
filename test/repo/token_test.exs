defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo.TokenTest do
  use WorkflowMetal.Storage.Adapters.Postgres.RepoCase

  alias WorkflowMetal.Storage.Adapters.Postgres.Repo.{Place, Case, Task, Token}

  @zero_uuid "00000000-0000-0000-0000-000000000000"

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

    task_schema = %Schema.Task{
      id: Ecto.UUID.generate(),
      workflow_id: workflow.id,
      transition_id: transition.id,
      case_id: workflow_case.id,
      state: :started
    }

    {:ok, task} = Task.insert_task(@config, task_schema)

    {:ok, {start_place, _end_place}} = Place.fetch_edge_places(@config, workflow.id)

    %{
      task: task,
      transition: transition,
      workflow: workflow,
      workflow_case: workflow_case,
      place: start_place
    }
  end

  describe "issue_token/2" do
    test "genesis", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place
    } do
      token_schema = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      assert {:ok, token} = Token.issue_token(@config, token_schema)
      assert token.state == :free
      assert token.produced_by_task_id == @zero_uuid
    end

    test "normal produced task", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_schema = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: task.id
      }

      assert {:ok, token} = Token.issue_token(@config, token_schema)
      assert token.state === :free
      assert token.produced_by_task_id === task.id
    end
  end

  describe "lock_tokens/3" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_schema = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(@config, token_schema)
      assert {:ok, [token]} = Token.lock_tokens(@config, [token.id], task.id)
      assert token.locked_by_task_id === task.id
      assert token.state === :locked
    end
  end

  describe "unlock_tokens/2" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_schema = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(@config, token_schema)
      {:ok, _tokens} = Token.lock_tokens(@config, [token.id], task.id)

      assert {:ok, [unlock_token]} = Token.unlock_tokens(@config, [token.id])
      assert unlock_token.state === :free
      assert is_nil(unlock_token.locked_by_task_id)
      assert unlock_token.id === token.id
    end
  end

  describe "consume_tokens/3" do
    test "by task", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_schema = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(@config, token_schema)
      {:ok, _tokens} = Token.lock_tokens(@config, [token.id], task.id)

      assert {:ok, [token]} = Token.consume_tokens(@config, [token.id], task.id)
      assert token.state == :consumed
      assert token.consumed_by_task_id == task.id
    end

    test "by termination case", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place
    } do
      token_schema = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token} = Token.issue_token(@config, token_schema)
      assert {:ok, [token]} = Token.consume_tokens(@config, [token.id], :termination)
      assert token.state == :consumed
      assert token.consumed_by_task_id === @zero_uuid
    end
  end

  describe "fetch_unconsumed_tokens/2" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place,
      task: task
    } do
      token_schema_1 = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      token_schema_2 = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token_1} = Token.issue_token(@config, token_schema_1)
      {:ok, token_2} = Token.issue_token(@config, token_schema_2)
      {:ok, [token_1]} = Token.lock_tokens(@config, [token_1.id], task.id)
      {:ok, [_token_1]} = Token.consume_tokens(@config, [token_1.id], task.id)

      assert {:ok, [token]} = Token.fetch_unconsumed_tokens(@config, workflow_case.id)
      assert token.id === token_2.id
    end
  end

  describe "fetch_tokens/2" do
    test "success", %{
      workflow: workflow,
      workflow_case: workflow_case,
      place: place
    } do
      token_schema_1 = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      token_schema_2 = %Schema.Token{
        id: Ecto.UUID.generate(),
        state: :free,
        workflow_id: workflow.id,
        case_id: workflow_case.id,
        place_id: place.id,
        produced_by_task_id: :genesis
      }

      {:ok, token_1} = Token.issue_token(@config, token_schema_1)
      {:ok, token_2} = Token.issue_token(@config, token_schema_2)

      assert {:ok, tokens} = Token.fetch_tokens(@config, [token_1.id, token_2.id])
      assert MapSet.new(tokens, & &1.id) === MapSet.new([token_1.id, token_2.id])
    end
  end
end
