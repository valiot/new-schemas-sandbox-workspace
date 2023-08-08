import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/wspace_ui start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER"), do:
  config :wspace_ui, WspaceUIWeb.Endpoint, server: true

if config_env() == :prod do
  
  workspace =
    "WORKSPACE" |> System.get_env("") |> String.upcase() |> Kernel.==("TRUE")

  internal_elixir_app_port = (
    System.get_env("CONTAINER_ELIXIR_APP_PORT") ||
      raise RuntimeError, """
      The environment variable CONTAINER_ELIXIR_APP_PORT is not set.
      """
  )

  config :wspace_ui,
    workspace: workspace,
    # The default value is meant to be used in a local machine. The environment
    # variable value is meant to be used in the docker compose network.
    task_timeout: "TASK_TIMEOUT" |> System.get_env("500") |> String.to_integer(),
    http_timeout: "HTTP_TIMEOUT" |> System.get_env("300") |> String.to_integer(),
    http_recv_timeout:
      "HTTP_RECV_TIMEOUT" |> System.get_env("100") |> String.to_integer(),

    # All composed workspace services ports and hosts
    services: %{
      wspace_ui: %{
        # Host of the service.
        # In local machine is alwas localhost. Within the docker compose network
        # it must be the container name in docker-compose.yml
        host: "wspace-ui",
        # Port set in the local machine as interface.
        host_port: (
          System.get_env("WSPACE_UI_PORT") ||
            raise RuntimeError, """
            The environment variable WSPACE_UI_PORT is not set.
            """
        ),
        # Port used within the docker compose network.
        network_port: (
          System.get_env("CONTAINER_ELIXIR_APP_PORT") ||
            raise RuntimeError, """
            The environment variable CONTAINER_ELIXIR_APP_PORT is not set.
            """
        )
      },

      ui: %{
        host: "ui",
        host_port: (
          System.get_env("UI_PORT") ||
            raise RuntimeError, """
            The environment variable UI_PORT is not set.
            """
        ),
        network_port: (
          System.get_env("CONTAINER_UI_PORT") ||
            raise RuntimeError, """
            The environment variable CONTAINER_UI_PORT is not set.
            """
        )
      },

      exp_627: %{
        host: "exp-627",
        host_port: (
          System.get_env("EXP_627_PORT") ||
            raise RuntimeError, """
            The environment variable EXP_627_PORT is not set.
            """
        ),
        network_port: (
          System.get_env("CONTAINER_EXP_627_PORT") ||
            raise RuntimeError, """
            The environment variable CONTAINER_EXP_627_PORT is not set.
            """
        )
      },

      worker: %{
        host: "worker",
        host_port: (
          System.get_env("WORKER_PORT") ||
            raise RuntimeError, """
            The environment variable WORKER_PORT is not set.
            """
        ),
        network_port: (
          System.get_env("CONTAINER_WORKER_PORT") ||
            raise RuntimeError, """
            The environment variable CONTAINER_WORKER_PORT is not set.
            """
        )
      },

      # Valiot-App services

      alerts: %{
        host: "alerts",
        host_port: (
          System.get_env("ALERTS_PORT") ||
            raise RuntimeError, """
            The environment variable ALERTS_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      auth: %{
        host: "auth",
        host_port: (
          System.get_env("AUTH_PORT") ||
            raise RuntimeError, """
            The environment variable AUTH_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      blog: %{
        host: "blog",
        host_port: (
          System.get_env("BLOG_PORT") ||
            raise RuntimeError, """
            The environment variable BLOG_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      eliot: %{
        host: "eliot",
        host_port: (
          System.get_env("ELIOT_PORT") ||
            raise RuntimeError, """
            The environment variable ELIOT_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      jobs: %{
        host: "jobs",
        host_port: (
          System.get_env("JOBS_PORT") ||
            raise RuntimeError, """
            The environment variable JOBS_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      notifications: %{
        host: "notifications",
        host_port: (
          System.get_env("NOTIFICATIONS_PORT") ||
            raise RuntimeError, """
            The environment variable NOTIFICATIONS_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      schedule_logic: %{
        host: "schedule-logic",
        host_port: (
          System.get_env("SCHEDULE_LOGIC_PORT") ||
            raise RuntimeError, """
            The environment variable SCHEDULE_LOGIC_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      ui_config: %{
        host: "ui-config",
        host_port: (
          System.get_env("UI_CONFIG_PORT") ||
            raise RuntimeError, """
            The environment variable UI_CONFIG_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      user: %{
        host: "user",
        host_port: (
          System.get_env("USER_PORT") ||
            raise RuntimeError, """
            The environment variable USER_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      # End of Valiot-App services

      valiot_app: %{ 
        host: "valiot-app",
        host_port: (
          System.get_env("VALIOT_APP_PORT") ||
            raise RuntimeError, """
            The environment variable VALIOT_APP_PORT is not set.
            """
        ),
        network_port: internal_elixir_app_port
      },

      pgadmin: %{
        host: "pgadmin",
        host_port: (
          System.get_env("PGADMIN_PORT") ||
            raise RuntimeError, """
            The environment variable PGADMIN_PORT is not set.
            """
        ),
        network_port: "80"
      }
    },
    setup_properties: %{
      apps_token: %{
        id: System.get_env("APP_TOKEN_ID", "0") |> String.to_integer(),
        request_header: %{
          Authorization: "Bearer #{System.get_env("APP_TOKEN")}"
        }
      },
      worker: %{
        name: System.get_env("WORKER_NAME"),
        code: System.get_env("WORKER_CODE"),
        token: %{
          id: System.get_env("WORKER_TOKEN_ID", "0") |> String.to_integer(),
          request_header: %{
            Authorization: "Bearer #{System.get_env("WORKER_TOKEN")}"
          }
        }
      },
      super_admin: %{
        email:     System.get_env("SUPER_USER_EMAIL"),
        password:  System.get_env("SUPER_USER_PASS"),
        name:      System.get_env("SUPER_USER_NAME"),
        last_name: System.get_env("SUPER_USER_LAST_NAME"),
        token: %{
          id: System.get_env("SUPER_USER_TOKEN_ID", "0") |> String.to_integer(),
          request_header: %{
            Authorization: "Bearer #{System.get_env("SUPER_USER_TOKEN")}"
          }
        }
      }
    }

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "wspace-ui"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :wspace_ui, WspaceUIWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :wspace_ui, WspaceUI.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILG
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
