defmodule Crawler.RootSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  def start_link(arg) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [], name: Crawler.Process.root_supervisor)
  end


  #######################
  ## Callback Functions
  #######################

  def init(arg) do
    children = [
      {Registry, keys: :unique, name: CrawlerRegistry},
      {Crawler.OperationManager, [{:via, Registry, {CrawlerRegistry, "OperationManager"}}]},
      {Crawler.DomainsSupervisor, []},
      {Crawler.DownloadWorkerSupervisor, [name: Crawler.DownloadWorkerSupervisor]},
      {Crawler.ScrapeWorkerSupervisor, [name: Crawler.ScrapeWorkerSupervisor]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
