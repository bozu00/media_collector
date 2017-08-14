defmodule Crawler.DownloadWorker do
  require Logger

  #######################
  ## Client API 
  #######################

  def start(url) do
    case is_valid_url?(url) do
      {:error, _} -> 
        #handle_response({:error, "unvalid_url"})
        ""
      {:ok, _} -> 
        res = HTTPoison.get(url,[],[recv_timeout: 20000])
        handle_response(res)
    end
  end

  #######################
  ## Privte Functions
  #######################

  defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body} })
  when code >= 200 and code <= 304 do
    # {:ok, body}
    body
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason} }) do
    Logger.info "worker [#{node}-#{inspect self}] error due to #{inspect reason}"
    # {:error, ""}
    ""
  end

  defp handle_response({_, _}) do
    # {:error, ""}
    ""
  end

  defp is_valid_url?(str) do
    uri = URI.parse(str)
    case uri do
      %URI{scheme: nil} -> {:error, uri}
      %URI{host: nil} -> {:error, uri}
      %URI{path: nil} -> {:error, uri}
      %URI{scheme: "http"}  -> {:ok, uri}
      %URI{scheme: "https"} -> {:ok, uri}
      _ -> {:error, uri}
    end 
  end

end
