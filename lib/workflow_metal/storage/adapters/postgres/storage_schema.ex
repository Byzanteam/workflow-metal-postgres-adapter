defprotocol WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
  @moduledoc false

  @doc "Transform schema to metal_schema"
  @spec transform(struct()) :: struct()
  def transform(schema)
end
