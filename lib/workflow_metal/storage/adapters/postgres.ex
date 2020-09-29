defmodule WorkflowMetal.Storage.Adapters.Postgres do
  @moduledoc """
  Storage adapter for WorkflowMetal.

  ```
  defmodule WorkflowStorage do
    use WorkflowMetal.Storage.Adapters.Postgres,
      rego: MyRepo,
      schema: MySchema
  end
  ```
  """

  defmacro __using__(options) do
    repo = Keyword.fetch!(options, :repo)
    schema = Keyword.fetch!(options, :schema)

    quote do
      @repo unquote(repo)
      @schema unquote(schema)

      alias WorkflowMetal.Storage.Adapters.Postgres.Repo
      import WorkflowMetal.Storage.Adapters.Util

      @behaviour WorkflowMetal.Storage.Adapter

      @impl true
      def child_spec(_application, _config) do
        {:ok, nil, [repo: @repo]}
      end

      # Workflow
      defaction Repo.Workflow.insert_workflow(workflow_schema, workflow_associations_params)
      defaction Repo.Workflow.fetch_workflow(workflow_id)
      defaction Repo.Workflow.delete_workflow(workflow_id)

      # Place
      defaction Repo.Place.fetch_edge_places(workflow_id)
      defaction Repo.Place.fetch_places(transition_id, arc_direction)

      # Transition
      defaction Repo.Transition.fetch_transition(transition_id)
      defaction Repo.Transition.fetch_transitions(place_id, arc_direction)

      # Arc
      defaction Repo.Arc.fetch_arcs(arc_beginning, arc_direction)

      # Case
      defaction Repo.Case.insert_case(case_schema)
      defaction Repo.Case.fetch_case(case_id)
      defaction Repo.Case.update_case(case_id, params)

      # Task
      defaction Repo.Task.insert_task(task_schema)
      defaction Repo.Task.fetch_task(task_id)
      defaction Repo.Task.fetch_tasks(case_id, options)
      defaction Repo.Task.update_task(task_id, params)

      # Token
      defaction Repo.Token.issue_token(token_schema)
      defaction Repo.Token.lock_tokens(token_ids, locked_by_task_id)
      defaction Repo.Token.unlock_tokens(token_ids)
      defaction Repo.Token.consume_tokens(token_ids, consumed_by_task_id)
      defaction Repo.Token.fetch_unconsumed_tokens(case_id)
      defaction Repo.Token.fetch_tokens(token_ids)

      # Workitem
      defaction Repo.Workitem.insert_workitem(workitem_schema)
      defaction Repo.Workitem.fetch_workitem(workitem_id)
      defaction Repo.Workitem.fetch_workitems(task_id)
      defaction Repo.Workitem.update_workitem(workitem_id, params)

      defp config(adapter_meta) do
        Keyword.merge(adapter_meta, repo: @repo, schema: @schema)
      end
    end
  end
end
