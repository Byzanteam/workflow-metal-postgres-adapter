defmodule WorkflowMetalPostgresAdapter.Utilities do
  @moduledoc false
  defmacro interface(module, name_arities) do
    quote bind_quoted: [module: module, name_arities: name_arities] do
      for {name, arity} <- name_arities do
        args = Macro.generate_arguments(arity, __MODULE__)

        def unquote(name)(unquote_splicing(args)) do
          case unquote(module).unquote(name)(unquote_splicing(args)) do
            {:ok, %schema{} = result} ->
              {:ok, schema.to_storage_schema(result)}

            {:ok, {%schema{} = result_1, %schema{} = result_2}} ->
              {:ok,
               {
                 schema.to_storage_schema(result_1),
                 schema.to_storage_schema(result_2)
               }}

            {:ok, []} ->
              {:ok, []}

            {:ok, [%schema{} | _] = results} ->
              {:ok, Enum.map(results, &schema.to_storage_schema(&1))}

            other ->
              other
          end
        end
      end
    end
  end
end
