defmodule TestStorage.Schema.Place do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  place_schema "places" do
    timestamps()
  end
end
