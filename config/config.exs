import Config

config :logger,
  backends: [:console],
  level: :info

if Mix.env() === :test do
  import_config "#{Mix.env()}.exs"
end
