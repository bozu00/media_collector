defmodule Crawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  #######################
  ## Callback Functions
  #######################

  def start(_type, _args) do
    children = [
      {Crawler.RootSupervisor,[]}
    ]

    #opts = [strategy: :one_for_one, name: Crawler.RootSupervisor]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
