defmodule WorkflowMetal.Storage.Adapters.Util do
  @moduledoc false

  alias WorkflowMetal.Storage.Adapters.Postgres.StorageSchema

  @doc """
  Delegate actions.

  ```elixir
  defaction Repo.Workflow.insert_workflow(workflow_schema, workflow_associations_params)
  ```

  Generate code:
  ```elixir
  @impl true
  def fetch_unconsumed_tokens(adapter_meta, workflow_schema, workflow_associations_params) do
    WorkflowMetal.Storage.Adapters.Util.to_storage_schema(
      Repo.Token.fetch_unconsumed_tokens(config(adapter_meta), workflow_schema, workflow_associations_params)
    )
  end
  ```
  """
  defmacro defaction(expr) do
    {
      {_, _, [_, action_name]},
      _,
      args
    } = expr

    fun_body =
      [do: config(adapter_meta)]
      |> quote()
      |> Macro.pipe(expr, 0)
      |> Macro.pipe(quote(do: unquote(__MODULE__).to_storage_schema()), 0)

    quote do
      @impl true
      def unquote(action_name)(adapter_meta, unquote_splicing(args)) do
        unquote(fun_body)
      end
    end
  end

  @doc "use StorageSchema protocol to transform to storage schema"
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
