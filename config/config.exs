# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :wechat,
  ecto_repos: [Wechat.Repo]

# Configures the endpoint
config :wechat, Wechat.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "F8heinmtYXN47EigLtjznR7hyf8HquhdQq366cN5loSL0HkGzv/MEK3zeyL7NaSO",
  render_errors: [view: Wechat.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Wechat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
