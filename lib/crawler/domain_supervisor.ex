defmodule Crawler.DomainSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  ## このモジュールはsimple_one_for_oneで監視されています
  ## start_childでの初期化が必要なために2変数関数にしています
  ## https://stackoverflow.com/questions/35964064/children-arguments-when-using-simple-one-for-one-strategy
  def start_link(empty, [domain] \\ ["def_arg"]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [domain], name: Crawler.Process.domain_supervisor(domain))
  end


  #######################
  ## Callback Function
  #######################

  def init([domain]) do
    children = [
      {Crawler.DownloadSupervisor, [domain]},
      {Crawler.JobsSupervisor, [domain]},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
