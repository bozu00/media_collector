defmodule Crawler.IOWorkerSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  def start_link(_) do
    Task.Supervisor.start_link(name: __MODULE__)
  end


  #######################
  ## Callback Function
  #######################

  def init(_)do
    children = [
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
