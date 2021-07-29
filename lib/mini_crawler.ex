defmodule MiniCrawler do
  def start() do
    base_url = get_url()
    depth = get_depth()
    IO.puts("Url: #{base_url}, Depth: #{depth}")

    web_pages = get_pages(base_url, depth)
    sitemap = build_sitemap(web_pages)
    display_info(web_pages, sitemap, [base_url])
  end

  defp display_info(web_pages, sitemap, history) do
    [current_page | _ ] = history
    %Page{assets: assets} = web_pages[current_page]
    [inbound_links, outbound_links] = get_links(sitemap, current_page)

    IO.puts("\n\n#{current_page}")
    print_assets(assets)
    IO.puts("\nInbound links:")
    print_links(inbound_links)
    IO.puts("\nOutbound links:")
    print_links(outbound_links)

    menu_loop(web_pages, sitemap, history, inbound_links, outbound_links)
  end

  defp menu_loop(web_pages, sitemap, history, inbound_links, outbound_links) do
    command = IO.gets("\n\n[o|i]number) to visit another page\nn) perform a new search\nq) quit\nb) go to previous page\n: ") |> String.trim()
    cond do
      outbound_links[command] ->
        display_info(web_pages, sitemap, [outbound_links[command] | history])
      inbound_links[command] ->
        display_info(web_pages, sitemap, [inbound_links[command] | history])
      command === "n" ->
        start()
      command === "b" ->
        if length(history) > 1 do
          display_info(web_pages, sitemap, ([ _| history] = history; history))
        else
          IO.puts("History is empty")
          menu_loop(web_pages, sitemap, history, inbound_links, outbound_links)
        end
      command === "q" ->
        System.stop()
      true ->
        IO.puts("Invalid input")
        menu_loop(web_pages, sitemap, history, inbound_links, outbound_links)
    end

  end

  defp print_links(links) do
    for {code, link} <- links do
      IO.puts("#{code}) #{link}")
    end
  end

  defp print_assets(assets) do
    IO.puts("===================================")
    IO.puts("Assets:")
    IO.puts("CSS")
    IO.inspect(assets.css)
    IO.puts("JS")
    IO.inspect(assets.js)
    IO.puts("IMG")
    IO.inspect(assets.img)
    IO.puts("===================================")
  end

  def get_links(sitemap, current_page) do
    outbound =
      for {edge, index} <- Enum.with_index(Graph.edges(sitemap, current_page), 1),
          edge.v1 == current_page,
          into: %{} do
        %Graph.Edge{v1: ^current_page, v2: out_link} = edge
        {"o#{index}", out_link}
      end

    inbound =
      for {edge, index} <- Enum.with_index(Graph.edges(sitemap, current_page), 1),
          edge.v2 == current_page,
          into: %{} do
        %Graph.Edge{v1: in_link, v2: ^current_page} = edge
        {"i#{index}", in_link}
      end

    [inbound, outbound]
  end

  defp build_sitemap(web_pages) do
    IO.puts("Building Graph...")
    {:ok, site_map} = SiteMap.start_link([])

    for {page_name, page} <- web_pages do
      for link <- page.links do
        SiteMap.add_edge(site_map, page_name, link)
      end
    end

    IO.puts("Done.")
    SiteMap.get_graph(site_map)
  end

  defp get_url() do
    url = IO.gets("please enter an url: ") |> String.trim()

    cond do
      Regex.match?(~r{(http|ftp|https)://([\w._-]+)}, url) ->
        Regex.replace(~r{/$}, url, "")

      true ->
        IO.puts("Ivalid url. \n")
        get_url()
    end
  end

  defp get_depth() do
    depth = IO.gets("please enter the maximum tree depth: ") |> String.trim()

    cond do
      Regex.match?(~r{^\d$}, depth) ->
        String.to_integer(depth)

      true ->
        IO.puts("Ivalid depth. \n")
        get_depth()
    end
  end

  defp get_pages(url, depth) do
    # initialize an Agent to keep url's data
    {:ok, pages} = Pages.start_link([])
    IO.puts("Crawling... Please wait...")
    Crawler.crawl(pages, url, url, depth)
    Pages.get_all(pages)
  end
end
