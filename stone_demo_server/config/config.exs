# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :stone_demo_server, StoneDemoServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rEaQCPZ5tAIxcquTrKUvX62gHgjMCi7kqzJjPuZEB36irRuS1iubEnFrwMFOs8SR",
  render_errors: [view: StoneDemoServer.ErrorView, accepts: ~w(html json)],
  pubsub: [name: StoneDemoServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
