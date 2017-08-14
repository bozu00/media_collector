defmodule RegistryTest do
  require Logger
  use GenServer

  #######################
  ## Client API 
  #######################

  def start_link(arg) do
    GenServer.start_link(__MODULE__, [])
  end

  #######################
  ## Callback Functions
  #######################
 
  def handle_call({:hello}, _from, state) do
    IO.puts("hello")
    IO.inspect self()
    {:reply, :ok, state}
  end
end

