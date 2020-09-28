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

  alias WorkflowMetal.Storage.Adapters.Postgres.StorageSchema

  defmacro __using__(options) do
    repo = Keyword.fetch!(options, :repo)
    schema = Keyword.fetch!(options, :schema)

    quote do
      @repo unquote(repo)
      @schema unquote(schema)

      alias WorkflowMetal.Storage.Adapters.Postgres.Repo

      @behaviour WorkflowMetal.Storage.Adapter

      @impl true
      def child_spec(_application, _config) do
        {:ok, nil, [repo: @repo]}
      end

      # Workflow

      @impl true
      def insert_workflow(adapter_meta, workflow_schema, workflow_associations_params) do
        adapter_meta
        |> config()
        |> Repo.Workflow.insert_workflow(workflow_schema, workflow_associations_params)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_workflow(adapter_meta, workflow_id) do
        adapter_meta
        |> config()
        |> Repo.Workflow.fetch_workflow(workflow_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def delete_workflow(adapter_meta, workflow_id) do
        adapter_meta
        |> config()
        |> Repo.Workflow.delete_workflow(workflow_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Place

      @impl true
      def fetch_edge_places(adapter_meta, workflow_id) do
        adapter_meta
        |> config()
        |> Repo.Place.fetch_edge_places(workflow_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_places(adapter_meta, transition_id, arc_direction) do
        adapter_meta
        |> config()
        |> Repo.Place.fetch_places(transition_id, arc_direction)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Transition

      @impl true
      def fetch_transition(adapter_meta, transition_id) do
        adapter_meta
        |> config()
        |> Repo.Transition.fetch_transition(transition_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_transitions(adapter_meta, place_id, arc_direction) do
        adapter_meta
        |> config()
        |> Repo.Transition.fetch_transitions(place_id, arc_direction)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Arc

      @impl true
      def fetch_arcs(adapter_meta, arc_beginning, arc_direction) do
        adapter_meta
        |> config()
        |> Repo.Arc.fetch_arcs(arc_beginning, arc_direction)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Case

      @impl true
      def insert_case(adapter_meta, case_schema) do
        adapter_meta
        |> config()
        |> Repo.Case.insert_case(case_schema)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_case(adapter_meta, case_id) do
        adapter_meta
        |> config()
        |> Repo.Case.fetch_case(case_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def update_case(adapter_meta, case_id, params) do
        adapter_meta
        |> config()
        |> Repo.Case.update_case(case_id, params)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Task

      @impl true
      def insert_task(adapter_meta, task_schema) do
        adapter_meta
        |> config()
        |> Repo.Task.insert_task(task_schema)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_task(adapter_meta, task_id) do
        adapter_meta
        |> config()
        |> Repo.Task.fetch_task(task_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_tasks(adapter_meta, case_id, options) do
        adapter_meta
        |> config()
        |> Repo.Task.fetch_tasks(case_id, options)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def update_task(adapter_meta, task_id, params) do
        adapter_meta
        |> config()
        |> Repo.Task.update_task(task_id, params)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Token

      @impl true
      def issue_token(adapter_meta, token_schema) do
        adapter_meta
        |> config()
        |> Repo.Token.issue_token(token_schema)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def lock_tokens(adapter_meta, token_ids, locked_by_task_id) do
        adapter_meta
        |> config()
        |> Repo.Token.lock_tokens(token_ids, locked_by_task_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def unlock_tokens(adapter_meta, token_ids) do
        adapter_meta
        |> config()
        |> Repo.Token.unlock_tokens(token_ids)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def consume_tokens(adapter_meta, token_ids, consumed_by_task_id) do
        adapter_meta
        |> config()
        |> Repo.Token.consume_tokens(token_ids, consumed_by_task_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_unconsumed_tokens(adapter_meta, case_id) do
        adapter_meta
        |> config()
        |> Repo.Token.fetch_unconsumed_tokens(case_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_tokens(adapter_meta, token_ids) do
        adapter_meta
        |> config()
        |> Repo.Token.fetch_tokens(token_ids)
        |> unquote(__MODULE__).to_storage_schema()
      end

      # Workitem

      @impl true
      def insert_workitem(adapter_meta, workitem_schema) do
        adapter_meta
        |> config()
        |> Repo.Workitem.insert_workitem(workitem_schema)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_workitem(adapter_meta, workitem_id) do
        adapter_meta
        |> config()
        |> Repo.Workitem.fetch_workitem(workitem_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def fetch_workitems(adapter_meta, task_id) do
        adapter_meta
        |> config()
        |> Repo.Workitem.fetch_workitems(task_id)
        |> unquote(__MODULE__).to_storage_schema()
      end

      @impl true
      def update_workitem(adapter_meta, workitem_id, params) do
        adapter_meta
        |> config()
        |> Repo.Workitem.update_workitem(workitem_id, params)
        |> unquote(__MODULE__).to_storage_schema()
      end

      defp config(adapter_meta) do
        Keyword.merge(adapter_meta, repo: @repo, schema: @schema)
      end
    end
  end

  def to_storage_schema({:ok, []}), do: {:ok, []}

  def to_storage_schema({:ok, schemas}) when is_list(schemas) do
    {:ok, Enum.map(schemas, &StorageSchema.transform/1)}
  end

  def to_storage_schema({:ok, {%schema{} = first, %schema{} = last}}) do
    {:ok,
     {
       StorageSchema.transform(first),
       StorageSchema.transform(last)
     }}
  end

  def to_storage_schema({:ok, schema}) do
    {:ok, StorageSchema.transform(schema)}
  end

  def to_storage_schema(error) do
    error
  end
end
