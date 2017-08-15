defmodule Crawler.IOSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  def start_link([path]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [path], name: __MODULE__)
  end


  #######################
  ## Callback Function
  #######################

  def init([path]) do
    children = [
      {Crawler.IOManager, [path]},
      {Crawler.IOWorkerSupervisor, []},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
