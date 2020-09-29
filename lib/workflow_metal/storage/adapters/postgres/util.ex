defmodule WorkflowMetal.Storage.Adapters.Util do
  @moduledoc false

  alias WorkflowMetal.Storage.Adapters.Postgres.StorageSchema

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
