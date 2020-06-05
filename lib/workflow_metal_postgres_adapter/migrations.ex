defmodule WorkflowMetalPostgresAdapter.Migrations do
  @moduledoc false

  use Ecto.Migration

  @initial_version 1
  @current_version 1

  def up(opts \\ []) when is_list(opts) do
    schema = repo_schema()
    prefix = repo_prefix()
    version = Keyword.get(opts, :version, @current_version)
    initial = min(migrated_version(repo(), schema, prefix) + 1, @current_version)

    if initial <= version, do: change(schema, prefix, initial..version, :up)
  end

  def down(opts \\ []) when is_list(opts) do
    schema = repo_schema()
    prefix = repo_prefix()
    version = Keyword.get(opts, :version, @initial_version)
    initial = max(migrated_version(repo(), schema, prefix), @initial_version)

    if initial >= version, do: change(schema, prefix, initial..version, :down)
  end

  def initial_version, do: @initial_version

  def current_version, do: @current_version

  def migrated_version(repo, schema, prefix) do
    query = """
    SELECT description
    FROM pg_class
    LEFT JOIN pg_description ON pg_description.objoid = pg_class.oid
    LEFT JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    WHERE pg_class.relname = '#{prefix}_workflows'
    AND pg_namespace.nspname = '#{schema}'
    """

    case repo.query(query) do
      {:ok, %{rows: [[version]]}} when is_binary(version) -> String.to_integer(version)
      _ -> 0
    end
  end

  defp change(schema, prefix, range, direction) do
    for index <- range do
      [__MODULE__, "V#{index}"]
      |> Module.concat()
      |> apply(direction, [schema, prefix])
    end
  end

  defp repo_schema do
    Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[:schema] ||
      "public"
  end

  defp repo_prefix do
    Application.get_env(:workflow_metal_postgres_adapter, WorkflowMetalPostgresAdapter)[:prefix] ||
      "workflow"
  end
end
