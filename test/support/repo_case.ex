defmodule WorkflowMetal.Storage.Adapters.Postgres.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias TestStorage.Repo

      @config [
        repo: TestStorage.Repo,
        schema: TestStorage.Schema
      ]
    end
  end

  setup tags do
    alias TestStorage.Repo
    alias Ecto.Adapters.SQL.Sandbox

    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
