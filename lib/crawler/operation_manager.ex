defmodule Crawler.OperationManager do
  use GenServer
  import Supervisor.Spec

  #######################
  ## Client API 
  #######################

  def start_link(arg) do
    GenServer.start_link(__MODULE__, [], name: Crawler.Process.operation_manager)
  end

  def issue_job(domain, job_name, info) do
    GenServer.call(Crawler.Process.operation_manager, {:issue_job, domain, job_name, info})
  end

  def all_job() do
    GenServer.call(Crawler.Process.operation_manager, {:all_job})
  end


  #######################
  ## Callback Function
  #######################

  def init(state) do
    :ets.new(:job_table, [:set, :protected, :named_table])
    {:ok, state}
  end

  def handle_call({:issue_job, domain, job_name, info}, _from, state) do
    #DomainSupervisorがなければ生成
    if Process.whereis(Crawler.Process.domain_supervisor(domain)) == nil do
      {:ok, agent1} = Supervisor.start_child(Crawler.Process.domains_supervisor, [[domain]] )
    end

    # jobがあったら:ngをかえす
    if Process.whereis(Crawler.Process.job_supervisor(domain,job_name)) != nil do
      IO.puts "JOBがダブってるよ"
      # TODO ここのエラーハンドリング処理を書く
      {:reply, :ng_dupulicate_job, state}
    end

    {:ok, agent1} = Supervisor.start_child(Crawler.Process.jobs_supervisor(domain), [[domain, job_name, info]]) 
    :ets.insert(:job_table, {[domain, job_name], [0, "working"]})
    {:reply, :ok, state}
  end

  def handle_call({:all_job}, _from, state) do
    list = :ets.match(:job_table, {[:"$1", :"$2"], [:"$3", :"$4"]})
    {:reply, list, state}
  end


  def handle_call({:end_of_job, domain, job_name}, _from, state) do
    ## statusをfinishedに更新
    [[count, _]] = :ets.match(:job_table, {[domain, job_name], [:"$1", :"$2"]})
    res = :ets.delete(:job_table, [domain, job_name])
    :ets.insert(:job_table, {[domain, job_name], [count, "finished"]})

    ## JobSupervisorを破棄
    Supervisor.terminate_child(Process.whereis(Crawler.Process.jobs_supervisor(domain)), Process.whereis(Crawler.Process.job_supervisor(domain, job_name)))
    {:reply, :ok, state}
  end

  def handle_cast({:increment_job, domain, job_name}, state) do
    [[count, status]] = :ets.match(:job_table, {[domain, job_name], [:"$1", :"$2"]})
    res = :ets.delete(:job_table, [domain, job_name])
    :ets.insert(:job_table, {[domain, job_name], [count+1, status]})
    {:noreply, state}
  end



end
