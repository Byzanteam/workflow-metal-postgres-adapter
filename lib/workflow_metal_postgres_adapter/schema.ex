defmodule WorkflowMetalPostgresAdapter.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: false}
      @foreign_key_type :binary_id

      @schema Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[:schema] || "public"
      @prefix Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[:prefix] || "workflow"
    end
  end
end
