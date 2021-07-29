defmodule Crawler do
  def crawl(pages_pid, base_url, current_url, depth) when depth > 0 do
    if !Pages.has_key?(pages_pid, current_url) do
      case HTTPoison.get(current_url, [], follow_redirect: true) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, document} = Floki.parse_document(body)
          urls = Floki.find(document, "a") |> Floki.attribute("href")
          internal_urls = filter_urls(urls, base_url)

          css_assets =
            Floki.find(document, "link[rel=\"stylesheet\"]")
            |> Floki.attribute("href")

          js_assets =
            Floki.find(document, "script")
            |> Floki.attribute("src")

          img_assets =
            Floki.find(document, "img")
            |> Floki.attribute("src")

          Pages.add(
            pages_pid,
            %Page{
              name: Regex.replace(~r(/{1,}$), current_url, ""),
              links: internal_urls,
              assets: %{
                css: css_assets,
                js: js_assets,
                img: img_assets
              }
            }
          )

          Enum.map(internal_urls, fn url ->
            Task.async(fn -> crawl(pages_pid, base_url, url, depth - 1) end)
          end)
          |> Enum.map(fn task -> Task.await(task, 30000) end)

        {:ok, %HTTPoison.Response{status_code: code, body: _body}} ->
          IO.puts("#{code} response for: #{current_url}")
          nil

        {:error, %HTTPoison.Error{reason: reason}} ->
          # Handle errors cases here
          IO.puts("HTTPoison.error, reason: #{reason}")
          nil
      end
    end

    :ok
  end

  def crawl(_pages_pid, _base_url, _current_url, 0) do
    :ok
  end

  defp filter_urls(urls, base_url) do
    internal_urls =
      Enum.reduce(urls, MapSet.new(), fn url, acc ->
        cond do
          Regex.match?(~r{^#{base_url}}, url) ->
            MapSet.put(acc, Regex.replace(~r(/{1,}$), url, ""))

          Regex.match?(~r{^/}, url) ->
            MapSet.put(acc, base_url <> Regex.replace(~r(/{1,}$), url, ""))

          true ->
            acc
        end
      end)

    MapSet.to_list(internal_urls)
  end
end
