defmodule CLI do
  require Logger

  def main(args) do
    # Application.get_env(:blitzy, :master_node)
    #   |> Node.start

    # Application.get_env(:blitzy, :slave_nodes)
    #   |> Enum.each(&Node.connect(&1))

    args
      |> parse_args
      |> process_options([node()|Node.list])

  end


  defp parse_args(args) do
    OptionParser.parse(args, 
                       aliases: [d: :dir],
                       strict: [dir: :string])
    # OptionParser.parse(args)
  end

  defp process_options(options, nodes) do
    case options do
      {[dir: d], [], []} ->
        IO.puts "Hello"
        IO.puts "file path to save html files is #{d}"

        children = [
          {Crawler.RootSupervisor,[[d]]}
        ]

        #opts = [strategy: :one_for_one, name: Crawler.RootSupervisor]
        opts = [strategy: :one_for_one]
        Supervisor.start_link(children, opts)


        :timer.sleep(:infinity)
      _ ->
        do_help

    end
  end

  # defp do_requests(n_requests, url, nodes) do
  #   Logger.info "Pummelling #{url} with #{n_requests} requests"

  #   total_nodes  = Enum.count(nodes)
  #   req_per_node = div(n_requests, total_nodes)

  #   IO.inspect(nodes)

  #   res = nodes
  #   |> Enum.flat_map(fn node ->
  #        1..req_per_node |> Enum.map(fn _ ->
  #          Task.Supervisor.async({TasksSupervisor, node}, Blitzy.Worker, :start, [url])
  #        end)
  #      end)
  #   |> Enum.map(&Task.await(&1, :infinity))
  #   # |> parse_results
  #   #
  #   IO.inspect res
  # end

  defp do_help do
    IO.puts """
    Usage:
    ./media_collector  --dir /tmp/media_collecor
    """
    System.halt(0)
  end

  # defp parse_results(results) do
  #   {successes, _failures} =
  #     results
  #       |> Enum.partition(fn x ->
  #            case x do
  #              {:ok, _} -> true
  #              _        -> false
  #          end
  #        end)

  #   total_workers = Enum.count(results)
  #   total_success = Enum.count(successes)
  #   total_failure = total_workers - total_success

  #   data = successes |> Enum.map(fn {:ok, time} -> time end)
  #   average_time  = average(data)
  #   longest_time  = Enum.max(data)
  #   shortest_time = Enum.min(data)

  #   IO.puts """
  #   Total workers    : #{total_workers}
  #   Successful reqs  : #{total_success}
  #   Failed reqs      : #{total_failure}
  #   Average (msecs)  : #{average_time}
  #   Longest (msecs)  : #{longest_time}
  #   Shortest (msecs) : #{shortest_time}
  #   """
  # end

  # defp average(list) do
  #   sum = Enum.sum(list)
  #   if sum > 0 do
  #     sum / Enum.count(list)
  #   else
  #     0
  #   end
  # end

end
