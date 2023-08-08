# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

localhost = "localhost"

config :wspace_ui,
  workspace: false,
  # The default value is meant to be used in a local machine. The environment
  # variable value is meant to be used in the docker compose network.
  task_timeout: 800,
  http_timeout: 500,
  http_recv_timeout: 300,

  # All composed workspace services ports and hosts
  services: %{
    wspace_ui: %{
      # Host of the service.
      # In local machine is alwas localhost.
      # Within the docker compose network must be the container name in 
      # docker-compose.yml
      host: localhost,
      # Port set in the local machine as interface.
      host_port: "4000",
      # Port used within the docker compose network.
      network_port: "4000"
    },

    ui:             %{host: localhost, host_port: "80", network_port: "80"},
    exp_627:        %{host: localhost, host_port: "8080", network_port: "8080"},
    worker:         %{host: localhost, host_port: "65432", network_port: "65432"},
    alerts:         %{host: localhost, host_port: "4002", network_port: "4000"},
    auth:           %{host: localhost, host_port: "4003", network_port: "4000"},
    blog:           %{host: localhost, host_port: "4004", network_port: "4000"},
    eliot:          %{host: localhost, host_port: "4005", network_port: "4000"},
    jobs:           %{host: localhost, host_port: "4006", network_port: "4000"},
    notifications:  %{host: localhost, host_port: "4007", network_port: "4000"},
    schedule_logic: %{host: localhost, host_port: "4008", network_port: "4000"},
    ui_config:      %{host: localhost, host_port: "4009", network_port: "4000"},
    user:           %{host: localhost, host_port: "4010", network_port: "4000"},
    valiot_app:     %{host: localhost, host_port: "4020", network_port: "4000"},
    pgadmin:        %{host: localhost, host_port: "5050", network_port: "80"}
  },
  setup_properties: %{
    apps_token: %{
      id: 1,
      request_header: %{
        Authorization: "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ2YWxpb3RfYXBwIiwiZXhwIjoxNjc4NTg0NDA2LCJpYXQiOjE2NzU5OTI0MDYsImlzcyI6InZhbGlvdF9hcHAiLCJqdGkiOiJlYTBkNjlhMy1iNDFiLTQyYjctOGU3OS05MzE3ODFhNzQ1NjIiLCJuYmYiOjE2NzU5OTI0MDUsInN1YiI6IiIsInR5cCI6ImFjY2VzcyJ9.YkodbRG0cuVbnbYoa3xEfW_vRuSx_YDsce6esPDEueeoFXAzxOKnazmS_6Hv3ozlkvTqHABB-ZrdHY2KnGuu6Q"
      }
    },
    worker: %{
      name: "WSPACE",
      code: "WSPACE",
      token: %{
        id: 2,
        request_header: %{
          Authorization: "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ2YWxpb3RfYXBwIiwiZXhwIjoxNjc4NTg0NDA2LCJpYXQiOjE2NzU5OTI0MDYsImlzcyI6InZhbGlvdF9hcHAiLCJqdGkiOiJjMjlkYTY1Yy05NjEwLTQyMjItOWRjMy0wOGM1ZDA1NjAxMTYiLCJuYmYiOjE2NzU5OTI0MDUsInN1YiI6IiIsInR5cCI6ImFjY2VzcyJ9.4HTY0M2H_lIsh1I84h9QwGxwIqHP6EAjo2Ibv1apHlfHy0m2qmnHdh5d0b0PoHZoAU92CwDgDXzstlVgBMT3Xw"
        }
      }
    },
    super_admin: %{
      email:     "super@admin.io",
      password:  "123-Abc.",
      name:      "John",
      last_name: "Doe",
      token: %{
        id: 3,
        request_header: %{
          Authorization: "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ2YWxpb3RfYXBwIiwiZXhwIjoxNjc4NjIwNDI4LCJpYXQiOjE2NzU5OTI0MjgsImlzcyI6InZhbGlvdF9hcHAiLCJqdGkiOiI0NmVkZDBiMy02ZTQ0LTRkNzAtYjM0OS0zZjgzM2JkNGNjZDIiLCJuYmYiOjE2NzU5OTI0MjcsInN1YiI6IjMiLCJ0b2tlbl9pZCI6MywidHlwIjoiYWNjZXNzIiwidXNlcl9pZCI6MX0.wAGjSjatUIBsNuI5RHsN-cH839Bb4R9HJoxe4pnecPHZ5Fku4QNrk3gNzK7pPbOynRDps7feEyaBMnqOHJa9Qg"
        }
      }
    }
  }

# Configures the endpoint
config :wspace_ui, WspaceUIWeb.Endpoint,
  url: [host: localhost],
  check_origin: :conn,
  pubsub_server: WspaceUI.PubSub,
  live_view: [signing_salt: "LS4A7/q0"],
  render_errors:
    [view: WspaceUIWeb.ErrorView, accepts: ~w(html json), layout: false]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :wspace_ui, WspaceUI.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
