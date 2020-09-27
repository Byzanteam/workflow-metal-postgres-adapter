defprotocol WorkflowMetal.Storage.Adapters.Postgres.StorageSchema do
  @doc "Transform schema to metal_schema"
  def transform(schema)
end
