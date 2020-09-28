defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo do
  defmacro __using__(_opts) do
    quote do
      alias Ecto.Multi

      defp get_repo(config) do
        Keyword.fetch!(config, :repo)
      end

      defp get_schema(name, config) do
        Module.concat(Keyword.fetch!(config, :schema), name)
      end

      defp repo_transaction(multi, config) do
        apply(get_repo(config), :transaction, [multi, config])
      end

      defp repo_get_by(queryable, clauses, config) do
        apply(get_repo(config), :get_by, [queryable, clauses, config])
      end

      defp repo_all(queryable, config) do
        apply(get_repo(config), :all, [queryable, config])
      end
    end
  end
end