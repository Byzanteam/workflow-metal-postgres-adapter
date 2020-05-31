defmodule WorkflowMetalPostgresAdapter.Repo do
  @moduledoc """
  WorkflowMetalPostgresAdapter repo for test.
  """
  use Ecto.Repo,
    otp_app: :workflow_metal_postgres_adapter,
    adapter: Ecto.Adapters.Postgres
end
