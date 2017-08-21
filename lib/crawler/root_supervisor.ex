defmodule Crawler.RootSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  def start_link([path]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [path], name: Crawler.Process.root_supervisor)
  end


  #######################
  ## Callback Functions
  #######################

  def init([path] \\ "/tmp/media_collector" ) do
    # argにconfを渡す
    children = [
      {Registry, keys: :unique, name: CrawlerRegistry},
      {Crawler.OperationManager, [{:via, Registry, {CrawlerRegistry, "OperationManager"}}]},
      {Crawler.IOSupervisor, [path]},
      {Crawler.DomainsSupervisor, []},
      {Crawler.DownloadWorkerSupervisor, [name: Crawler.DownloadWorkerSupervisor]},
      {Crawler.ScrapeWorkerSupervisor, [name: Crawler.ScrapeWorkerSupervisor]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
