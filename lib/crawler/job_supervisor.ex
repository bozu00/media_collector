defmodule Crawler.JobSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  ## このモジュールはsimple_one_for_oneで監視されています
  ## start_childでの初期化が必要なために2変数関数にしています
  ## https://stackoverflow.com/questions/35964064/children-arguments-when-using-simple-one-for-one-strategy
  def start_link(dummy, [domain,job_name,info] = arg \\ ["", "dummy", ""]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [domain, job_name, info], name: Crawler.Process.job_supervisor(domain, job_name))
  end

  #######################
  ## Callback Functions
  #######################

  def init([domain, job_name, info]) do 
    children = case job_name do
      "dummy" -> []
      _ -> [
        {Crawler.ScrapeManager, [domain, job_name, info]}
      ]
    end

    Supervisor.init(children, strategy: :one_for_one)
  end

end
