defmodule Crawler.ScrapeManager do
  use GenServer
  @moduledoc """
  スクレイピングするプロセス
  """

  #######################
  ## Client API 
  #######################
  
  def start_link([domain, job_name, info]) do
    GenServer.start_link(__MODULE__, [Qex.new, domain, job_name ,info], name: Crawler.Process.scrape_manager(domain,job_name))
  end

  #######################
  ## Callback Functions
  #######################
 
  def init([queue, domain, job_name, info] = state) do
    :ok  = GenServer.cast(Crawler.Process.download_manager(domain), {:download, job_name, :index, info.first_index_page})
    {:ok, state}
  end

  def handle_cast({:finish_download, job_name, :index, url, body}, [queue, domain, job_name, info] = state) do

    {_, detail_link_list} = 
      Task.Supervisor.async(Crawler.ScrapeWorkerSupervisor, Crawler.ScrapeWorker, :scrape, [:detail_links, body, url, info.detail_link_selector])
      |> Task.await

    # 詳細ページのダウンロード依頼
    detail_link_list 
    |> Enum.map(fn detail_url ->  
      :ok = GenServer.cast(Crawler.Process.download_manager(domain), {:download, job_name, :detail, detail_url})
    end)

    {_, next_index_link} = 
      Task.Supervisor.async(Crawler.ScrapeWorkerSupervisor, Crawler.ScrapeWorker, :scrape, [:next_index_link, body, url, info.next_link_selector])
      |> Task.await

    # 一覧ページのダウンロード依頼 
    case next_index_link do
      x when x == "" ->
        :ok  = GenServer.cast(Crawler.Process.download_manager(domain), {:end_of_job, job_name})
      x ->
        :ok = GenServer.cast(Crawler.Process.download_manager(domain), {:download, job_name, :index, x})
    end

    {:noreply, [queue, domain, job_name, info] }
  end


  def handle_cast({:finish_download, job_name, :detail, url, body}, [queue, domain, job_name, info] = state) do
    #new_queue = Qex.push(queue, [job_name, :detail, url, body])
    {_, content} = 
      Task.Supervisor.async(Crawler.ScrapeWorkerSupervisor, Crawler.ScrapeWorker, :scrape, [:content, body, info.detail_content_selector])
      |> Task.await

    content |> String.slice(0, 30) |> IO.puts
    ##  IO.puts "DBにcontentを挿入!"
    
    :ok = GenServer.cast(Crawler.IOManager, {:file_out, job_name, url, content})

    # {{_, item}, new_queue} = Qex.pop(queue)

    #詳細ページのスクレイピング終了をOperationManagerに通知
    :ok = GenServer.cast(Crawler.Process.operation_manager, {:increment_job, domain, job_name})

    {:noreply, [queue, domain, job_name, info]}
  end


  def handle_cast({:rep_end_of_job, job_name}, [queue, domain, job_name, info] = state) do
    case Enum.empty? queue do
      true -> 
        :ok = GenServer.call(Crawler.Process.operation_manager, {:end_of_job, domain, job_name})
        IO.puts "rep_end_of_job Accepted"
      false ->
        # 空じゃなかったらまたもう一回自分に送っておく
        :ok = GenServer.cast(self(), {:rep_end_of_job, job_name})
    end

    {:noreply, state}
  end
end
