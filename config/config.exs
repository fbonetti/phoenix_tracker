# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :phoenix_tracker, PhoenixTracker.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "KqRZqtS7SEl8EmwQE9Brhib3fDJJ74PTTlD0npiroCVbxLh7kEk7bMWyfWM2jOtu",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: PhoenixTracker.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix_tracker,
  spot_api_key: System.get_env("SPOT_API_KEY"),
  forecast_io_api_key: System.get_env("FORECAST_IO_API_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
