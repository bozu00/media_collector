defmodule Crawler.IOWorker do
  require Logger

  #######################
  ## Client API 
  #######################

  def write(dir_path, job_name, url, content) do
    dir = Path.join(Path.split(dir_path) ++ [job_name])
    # File.dir? dir
    unless File.exists? dir  do
      File.mkdir_p dir 
    end

    file_path = Path.join(Path.split(dir_path) ++ [job_name, url2filename(url)]) 
    File.write file_path, content
    # TODO 書き込みがOKだったかどうかのハンドリングを書く
    {:ok, file_path}
  end

  #######################
  ## Privte Functions
  #######################

  defp url2filename(url) do
    IO.puts url
    parsed = URI.parse(url)
    IO.inspect parsed



    if is_nil(parsed.query) do
      filepath = parsed.host <> parsed.path
    else
      filepath = parsed.host <> parsed.path <> "__" <> parsed.query
    end
    IO.puts filepath

    filepath 
    |> String.replace(".", "_")
    |> String.replace("/", "_")
  end

end
