defmodule Crawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application


  #######################
  ## Client API 
  #######################

  def start_crawler(path) do
    children = [
      {Crawler.RootSupervisor,[path]}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  #######################
  ## Callback Functions
  #######################

  def start(_type, _args) do
    IO.puts"_args"
    IO.inspect _args
    children = [
      {Crawler.RootSupervisor,[]}
    ]

    #opts = [strategy: :one_for_one, name: Crawler.RootSupervisor]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

end
