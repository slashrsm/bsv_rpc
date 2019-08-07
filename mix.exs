defmodule BsvRpc.MixProject do
  use Mix.Project

  defp description do
    "Bitcoin SV JSON-RPC client."
  end

  def project do
    [
      app: :bsv_rpc,
      version: "0.1.0",
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
      aliases: [
        quality: ["format", "credo --strict", "dialyzer", "test"],
        "quality.ci": [
          "test",
          "format --check-formatted",
          "credo --strict",
          "dialyzer --halt-exit-status"
        ]
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
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.7", only: [:dev, :test], runtime: false},
      {:mock, "~> 0.3.3", only: :test}
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
