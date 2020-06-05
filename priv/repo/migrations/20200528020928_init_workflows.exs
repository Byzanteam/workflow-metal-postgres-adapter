defmodule WorkflowMetalPostgresAdapter.Repo.Migrations.InitWorkflows do
  use Ecto.Migration

  def up do
    WorkflowMetalPostgresAdapter.Migrations.up()
  end

  def down do
    WorkflowMetalPostgresAdapter.Migrations.down()
  end
end
