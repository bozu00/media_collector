defmodule Crawler.DomainsSupervisor do
  use Supervisor

  #######################
  ## Client API 
  #######################

  def start_link([]) do
    result = {:ok, sup }  = Supervisor.start_link(__MODULE__, [], name: Crawler.Process.domains_supervisor)
  end

  def start_child([domain]) do
    Supervisor.start_child(Crawler.Process.domains_supervisor, [domain])
  end

  #######################
  ## Callback Function
  #######################

  def init(arg) do
    IO.puts __MODULE__

    children = [
      {Crawler.DomainSupervisor, ["dummy-domain-supervisor"]},
    ]
    IO.inspect children

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
