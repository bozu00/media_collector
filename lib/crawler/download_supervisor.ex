defmodule Crawler.DownloadSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################
  
  def start_link([domain]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [domain], name: String.to_atom("#{domain}_download_supervisor"))
  end


  #######################
  ## Callback Function
  #######################

  def init(domain) do
    children = [
      {Crawler.DownloadManager, [domain]},
      {Crawler.Downloader, domain}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end

