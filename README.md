# WorkflowMetalPostgresAdapter

Workflow Metal Postgres adapter.

## Use

* Define Schema and Repo. (more detail in `test/support/test_storage/`)

```elixir
defmodule TestStorage.Repo do
  use Ecto.Repo,
    otp_app: :workflow_metal_postgres_adapter,
    adapter: Ecto.Adapters.Postgres
end

defmodule TestStorage.Schema do
  @moduledoc false

  import WorkflowMetal.Storage.Adapters.Postgres.Schema

  workflow_schema "workflows" do
    timestamps()
  end

  place_schema "places" do
    timestamps()
  end

  transition_schema "transitions",
    join_type: TestStorage.TransitionTypes.JoinTypeEnum,
    split_type: TestStorage.TransitionTypes.SplitTypeEnum do
    timestamps()
  end

  arc_schema "arcs" do
    timestamps()
  end

  case_schema "cases" do
    timestamps()
  end

  token_schema "tokens" do
    timestamps()
  end

  task_schema "tasks" do
    timestamps()
  end

  workitem_schema "workitems" do
    timestamps()
  end
end
```

* Use storage in Workflow Application, pass the application repo and schema.

```elixir
  defmodule Workflow do
    use WorkflowMetal.Application,
      registry: WorkflowMetal.Registration.LocalRegistry,
      storage: {
        WorkflowMetal.Storage.Adapters.Postgres,
        repo: TestStorage.Repo, schema: TestStorage.Schema
      }
  end
```

## Test in shell

* Migrate repo first.

```shell
MIX_ENV=test iex --dot-iex examples/traffic_light.exs -S mix
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `workflow_metal_postgres_adapter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:workflow_metal_postgres_adapter, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/workflow_metal_postgres_adapter](https://hexdocs.pm/workflow_metal_postgres_adapter).
