defmodule TestStorage.Schema.Token do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  token_schema "tokens" do
    timestamps()
  end
end
