defmodule BsvRpc.MixProject do
  use Mix.Project

  defp description do
    "Bitcoin SV JSON-RPC client."
  end

  def project do
    [
      app: :bsv_rpc,
      version: "1.0.0-alpha3",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/slashrsm/bsv_rpc",
      description: description(),
      package: package(),
      deps: deps(),
      elixirc_options: [warnings_as_errors: true],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BsvRpc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_check, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:mock, "~> 0.3.3", only: :test},
      {:httpoison, "~> 1.5"},
      {:poison, "~> 4.0"},
      {:libsecp256k1, "~> 0.1.10"},
      {:mnemonic, "~> 0.1.0", hex: :mnemonic_ex},
      {:extended_key, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Janez Urevc"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/slashrsm/bsv_rpc"}
    ]
  end
end
