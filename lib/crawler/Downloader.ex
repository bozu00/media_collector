defmodule Crawler.Downloader do
  use GenServer
  require Logger

  #######################
  ## Client API 
  #######################

  def start_link([domain]) do
    GenServer.start_link(__MODULE__, [domain], name: Crawler.Process.downloader(domain))
  end


  #######################
  ## Callback Functions
  #######################

  ## TODO initでキューを取ってくる処理を書く
  ## statusを返す処理を書く
  def handle_cast({:download, job_name, category_atom, url}, [domain] = state) do
    body = 
      Task.Supervisor.async(Crawler.DownloadWorkerSupervisor, Crawler.DownloadWorker, :start, [url])
      |> Task.await

    :timer.sleep(1000)

    :ok = GenServer.cast(Crawler.Process.download_manager(domain), {:finish_download, job_name, category_atom, url, body})
    {:noreply, state}
  end

  def handle_cast({:end_of_job, job_name}, [domain] = state) do
    :ok = GenServer.cast(Crawler.Process.download_manager(domain), {:rep_end_of_job, job_name})
    {:noreply, state}
  end

  defp handle_response({:ok, body}) do
    body
  end

  defp handle_response({:error, reason}) do
    Logger.info "reason: #{reason}"
    ""
  end

end
