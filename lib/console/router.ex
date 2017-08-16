defmodule Console.Router do
  use Trot.Router
  use Trot.Template

  @template_root "templates"

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]


  # Setup a static route to priv/static/assets
  static "/css", "assets"

  # Sets the status code to 200 with a text body
  get "/test" do
    "application is running"
  end

  get "/jobs" do
    list = Crawler.OperationManager.all_job()
    render_template("all_job.html.eex", [job_list: list])
  end

  post "/jobs" do 
    list = Crawler.OperationManager.all_job()
    render_template("all_job.html.eex", [job_list: list])
  end

  get "/new_job" do
    render_template("new_job.html.eex", [])
  end

  post "/regist_job" do
    {:ok, body_string, conn} = Plug.Conn.read_body(conn)
    info = URI.decode_query(body_string)
    domain = URI.parse(info["first_index_page"]).authority
    job_name = info["job_name"]
    info["first_index_page"]

    info = %{
      first_index_page: info["first_index_page"],
      detail_link_selector: info["detail_link_selector"],
      next_link_selector: info["next_link_selector"],
      detail_content_selector: info["detail_content_selector"]
    }

    Crawler.OperationManager.issue_job(domain, job_name, info)
    {301, "" , %{"Location" => "/jobs"}}
  end


  post "/confirm_job" do
    {:ok, body_string, conn} = Plug.Conn.read_body(conn)
    info = URI.decode_query(body_string)
    IO.inspect info

    body = 
      Task.Supervisor.async(Crawler.DownloadWorkerSupervisor, Crawler.DownloadWorker, :start, [info["first_index_page"]])
      |> Task.await(10000)

    {code, detail_link_list} = 
      Task.Supervisor.async(Crawler.ScrapeWorkerSupervisor, Crawler.ScrapeWorker, :scrape, [:detail_links, body, info["first_index_page"], info["detail_link_selector"]])
      |> Task.await
    IO.inspect detail_link_list

    {_, next_index_link} = 
      Task.Supervisor.async(Crawler.ScrapeWorkerSupervisor, Crawler.ScrapeWorker, :scrape, [:next_index_link, body, info["first_index_page"], info["next_link_selector"]])
      |> Task.await
    IO.inspect next_index_link 

    detail_page = case detail_link_list do
      [] -> ""
      [first|_] -> 
        Task.Supervisor.async(Crawler.DownloadWorkerSupervisor, Crawler.DownloadWorker, :start, [first])
        |> Task.await(10000)
    end

    {_, content1} = 
      Task.Supervisor.async(Crawler.ScrapeWorkerSupervisor, Crawler.ScrapeWorker, :scrape, [:content, detail_page, info["detail_content_selector"]])
      |> Task.await
    IO.puts content1
    
    render_template("regist_job.html.eex", [info: info, content1: content1, detail_link_list: detail_link_list, next_index_link: next_index_link])
  end

  import_routes Trot.NotFound
end
