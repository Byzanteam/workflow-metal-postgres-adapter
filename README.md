# WorkflowMetalPostgresAdapter

Workflow Metal Postgres adapter.

## Use

* Add config for `schema` and `prefix`. Default are `public` and `workflow`

```elixir
config :workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter,
  schema: "public",
  prefix: "workflow"
```

* Use storage in Workflow Application, pass the application repo.

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
