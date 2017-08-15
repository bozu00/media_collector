defmodule Crawler.IOManager do
  use GenServer
  @moduledoc """
  IOを行うアクター
  """

  #######################
  ## Client API 
  #######################

  def start_link([path]) do
    GenServer.start_link(__MODULE__, [path], name: __MODULE__)
  end

  #######################
  ## Callback Function
  #######################
  
  def init([path]) do
    IO.puts __MODULE__
    {:ok, [path]}
  end

  def handle_cast({:file_out, job_name, url, content}, [path]) do
    {code, file_path} = 
      Task.Supervisor.async(Crawler.IOWorkerSupervisor, Crawler.IOWorker, :write, [path, job_name, url, content])
      |> Task.await

    case code do 
      :ok ->  IO.puts "succuess to write #{file_path}"
      :error -> IO.puts "fail to write #{file_path}"
    end

    {:noreply, [path]}
  end
end
