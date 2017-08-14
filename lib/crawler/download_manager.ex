defmodule Crawler.DownloadManager do
  use GenServer

  @moduledoc """
  ただキューを管理するだけのManager
  """

  #######################
  ## Client API 
  #######################

  def start_link(domain) do
    GenServer.start_link(__MODULE__, [Qex.new, domain], name: Crawler.Process.download_manager(domain))
  end


  #######################
  ## Callback Function
  #######################

  def handle_cast({:download, job_name, category_atom, url}, [queue, domain] = state) do
    new_queue = Qex.push(queue, [job_name, category_atom, url])
    :ok  = GenServer.cast(Crawler.Process.downloader(domain), {:download, job_name, category_atom, url})
    {:noreply, [new_queue, domain]}
  end


  def handle_cast({:finish_download, job_name, category_atom, url, body}, [queue, domain] = state) do
    {{_, item}, new_queue} = Qex.pop(queue)
    # statusでエラーハンドリングしないでそのまま渡す
    # 失敗だったら""が帰ってきている
    :ok = GenServer.cast(Crawler.Process.scrape_manager(domain,job_name), {:finish_download, job_name, category_atom, url, body})
    {:noreply, [new_queue, domain]}
  end


  def handle_cast({:end_of_job, job_name}, [queue, domain] = state) do
    :ok  = GenServer.cast(Crawler.Process.downloader(domain), {:end_of_job, job_name})
    {:noreply, state}
  end

  def handle_cast({:rep_end_of_job, job_name}, [queue, domain] = state) do
    :ok  = GenServer.cast(Crawler.Process.scrape_manager(domain, job_name), {:rep_end_of_job, job_name})
    {:noreply, state}
  end


  #TODO
  @doc """
  Downloader再起動時にキューの中身をメッセージとしてDownloaderにcastする関数
  Downloaderから呼ばれる
  """
  def handle_call({:dequeue}, _from, [queue, domain] = state) do
    {{_, item}, new_queue} = Qex.pop(queue)
    {:reply, item, [new_queue, domain]}
  end

end
