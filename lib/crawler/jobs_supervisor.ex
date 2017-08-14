defmodule Crawler.JobsSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  def start_link([domain]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [domain], name: Crawler.Process.jobs_supervisor(domain))
  end


  #######################
  ## Callback Functions
  #######################

  def init([domain]) do
    children = [
      {Crawler.JobSupervisor, [] }
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end

end
