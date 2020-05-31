defmodule WorkflowMetalPostgresAdapter.Schema do
  @moduledoc """
  WorkflowMetalPostgresAdapter custom schema
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: false}
      @foreign_key_type :binary_id

      @schema Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[
                :schema
              ] || "public"
      @prefix Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[
                :prefix
              ] || "workflow"
    end
  end
end