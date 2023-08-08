defmodule WspaceUI.MixProject do
  use Mix.Project

  def project do
    [
      app: :wspace_ui,
      version: "1.5.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # ExDocs documentation
      name: "Composed Workspace",
      homepage_url: "http://localhost:4000/",
      source_url: "https://github.com/valiot/Composed-Workspace",
      docs: [
        authors: ["Valiot"],
        main: "readme",
        source_ref: "develop",
        extra_section: "PAGES",
        logo: "priv/static/images/logo.png",
        assets: "priv/static/images",
        output: "priv/static/doc",
        api_reference: false,
        filter_modules: fn _, _ -> false end,
        extras: [
          "README.md":    [title: "README"],
          "CHANGELOG.md": [title: "CHANGELOG"]
        ],
        javascript_config_path: nil
      ],
      releases: [
        # :validate_compile_env is set to false in order to have different
        # environment variables values in compilation and run times (Behaviour
        # due to it can run in a local machine and with docker-compose).
        wspace_ui: [validate_compile_env: false]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WspaceUI.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.15"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:ex_doc, "~> 0.19"},
      {:httpoison, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
