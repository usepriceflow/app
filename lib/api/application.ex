defmodule PriceFlow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PriceFlowWeb.Telemetry,
      PriceFlow.Repo,
      {DNSCluster, query: Application.get_env(:api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PriceFlow.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PriceFlow.Finch},
      # Start a worker by calling: PriceFlow.Worker.start_link(arg)
      # {PriceFlow.Worker, arg},
      # Start to serve requests, typically the last entry
      PriceFlowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PriceFlow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PriceFlowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
