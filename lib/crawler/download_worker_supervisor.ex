defmodule Crawler.DownloadWorkerSupervisor do
  use Supervisor

  @moduledoc """
  スクレイピングするプロセス
  """

  #######################
  ## Client API 
  #######################

  def start_link(_) do
    Task.Supervisor.start_link(name: __MODULE__ )
  end


  #######################
  ## Callback Functions
  #######################

  def init(_) do
    IO.puts __MODULE__

    children = [
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
