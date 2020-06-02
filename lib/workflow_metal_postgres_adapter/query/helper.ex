defmodule WorkflowMetalPostgresAdapter.Query.Helper do
  @moduledoc false

  @genesis_uuid "00000000-0000-0000-0000-000000000000"

  @spec repo(Keyword.t()) :: module()
  def repo(adapter_meta) do
    Keyword.fetch!(adapter_meta, :repo)
  end

  @spec reversed_arc_direction(atom()) :: atom()
  def reversed_arc_direction(:in), do: :out
  def reversed_arc_direction(:out), do: :in

  @spec uuid() :: Ecto.UUID.t()
  def uuid, do: do_uuid()

  @spec now() :: NaiveDateTime.t()
  def now do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  def do_uuid(value \\ nil)
  def do_uuid(nil), do: do_uuid(Ecto.UUID.generate())
  def do_uuid(@genesis_uuid), do: do_uuid()
  def do_uuid(uuid), do: uuid
end
