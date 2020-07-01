defprotocol WorkflowMetalPostgresAdapter.Schema.DynamicalEnum do
  def cast_enum_fields(_, params, config)
  def load_enum_fields(record, config)
end

defmodule WorkflowMetalPostgresAdapter.Schema.DynamicalEnum.Helper do
  @moduledoc false

  defmacro __using__(model_name: model_name, enum_fields: enum_fields) do
    quote location: :keep do
      defimpl WorkflowMetalPostgresAdapter.Schema.DynamicalEnum do
        def cast_enum_fields(_, params, config) do
          enum_types = Keyword.fetch!(config, unquote(model_name))

          Enum.reduce(unquote(enum_fields), params, fn field, acc ->
            value = Map.get(params, field)

            if is_nil(value) do
              params
            else
              type = Keyword.fetch!(enum_types, field)
              {:ok, value} = type.cast(value)
              {:ok, value} = type.dump(value)
              Map.put(acc, field, value)
            end
          end)
        end

        def load_enum_fields(record, config) do
          enum_types = Keyword.fetch!(config, unquote(model_name))

          Enum.reduce(unquote(enum_fields), record, fn field, acc ->
            value = Map.get(record, field)

            if is_nil(value) do
              record
            else
              type = Keyword.fetch!(enum_types, field)
              {:ok, value} = type.load(value)
              Map.put(acc, field, value)
            end
          end)
        end
      end
    end
  end
end
