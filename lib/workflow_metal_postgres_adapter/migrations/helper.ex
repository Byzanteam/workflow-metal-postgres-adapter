defmodule WorkflowMetalPostgresAdapter.Migrations.Helper do
  @moduledoc false
  use Ecto.Migration

  defmacro now do
    quote do
      fragment("timezone('UTC', now())")
    end
  end

  def record_version(schema, prefix, version) do
    execute("COMMENT ON TABLE #{schema}.#{prefix}_workflows IS '#{version}'")
  end
end
