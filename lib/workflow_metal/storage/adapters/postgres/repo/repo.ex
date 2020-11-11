defmodule WorkflowMetal.Storage.Adapters.Postgres.Repo do
  @moduledoc false

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

      defp repo_insert(struct_or_changeset, config) do
        apply(get_repo(config), :insert, [struct_or_changeset, config])
      end

      defp repo_update(changeset, config) do
        apply(get_repo(config), :update, [changeset, Keyword.put(config, :returning, true)])
      end

      defp repo_get_by(queryable, clauses, config) do
        apply(get_repo(config), :get_by, [queryable, clauses, config])
      end

      defp repo_all(queryable, config) do
        apply(get_repo(config), :all, [queryable, config])
      end

      defp get_pk_name(name, config) do
        schema = get_schema(name, config)
        "#{schema.__schema__(:source)}_pkey"
      end
    end
  end
end
