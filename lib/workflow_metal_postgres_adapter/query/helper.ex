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
  def uuid, do: uuid(Ecto.UUID.generate())

  @spec uuid(term()) :: Ecto.UUID.t()
  def uuid(nil), do: uuid(Ecto.UUID.generate())
  def uuid(@genesis_uuid), do: uuid(nil)

  def uuid(uuid) do
    case Ecto.UUID.cast(uuid) do
      :error ->
        uuid(Ecto.UUID.generate())

      {:ok, uuid} ->
        uuid
    end
  end

  @spec now() :: NaiveDateTime.t()
  def now do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  def repo_schema do
    Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[:schema] ||
      "public"
  end
end
