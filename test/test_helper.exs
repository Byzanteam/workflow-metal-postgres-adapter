ExUnit.start()

TestStorage.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(TestStorage.Repo, :manual)
