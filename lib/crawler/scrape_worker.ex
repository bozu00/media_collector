defmodule Crawler.ScrapeWorker do
  require Logger

  #######################
  ## Client API 
  #######################

  def scrape(:detail_links, body, url, detail_link_selector) do
    body 
    |> Floki.find(detail_link_selector) 
    |> Floki.attribute("href") 
    |> Enum.map(ensure_absolute_path(url)) # ["http://howcollect.jp/article/27261", "http://howcollect.jp/article/27257"]
    |> case do
      [] -> {:error, []}
      x  -> {:ok, x}
    end
  end

  def scrape(:next_index_link, body, url, next_link_selector) do
    body 
    |> Floki.find(next_link_selector) 
    |> Floki.attribute("href") 
    |> Enum.at(0) # next_link = "http://howcollect.jp/list/index/category/11000/?page=2"
    |> valid_next_index_url(url)
    |> case do
      "" -> {:error, ""}
      x  -> {:ok, x}
    end
  end


  def scrape(:content, body, content_selector) do
    body 
    |> Floki.find(content_selector) 
    |> Floki.raw_html 
    |> HtmlSanitizeEx.strip_tags
    |> case do
      "" -> {:error, ""}
      x  -> {:ok, x}
    end
  end

  #######################
  ## Privte Functions
  #######################

  defp valid_next_index_url(next_link, first_index_url) do
    next_index_link = case next_link do
      x when x == nil or x == "" -> ""
      x -> ensure_absolute_path(first_index_url).(x)
    end
  end

  def ensure_absolute_path(origin_url) do
    fn url -> 
      origin_parsed = URI.parse(origin_url)
      origin_domain = origin_parsed.authority
      origin_scheme = origin_parsed.scheme

      parsed = URI.parse(url)
      path   = parsed.path
      query  = parsed.query

      case query do
        nil -> "#{origin_scheme}://#{origin_domain}#{path}"
        x -> "#{origin_scheme}://#{origin_domain}#{path}?#{query}"
      end
    end
  end
end

