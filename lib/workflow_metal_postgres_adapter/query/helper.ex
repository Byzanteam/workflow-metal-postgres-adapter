defmodule WorkflowMetalPostgresAdapter.Query.Helper do
  def repo(adapter_meta) do
    Application.get_env(:workflow_metal_postgres_adapter, adapter_meta)[:repo]
  end

  def reversed_arc_direction(:in), do: :out
  def reversed_arc_direction(:out), do: :in

  def uuid, do: Ecto.UUID.generate()

  def now do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end
end
