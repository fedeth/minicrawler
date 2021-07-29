defmodule SiteMap do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> Graph.new() end)
  end

  def add_edge(pid, v1, v2) do
    Agent.update(pid, fn site_map ->
      Graph.add_edge(site_map, v1, v2)
    end)
  end

  def get_graph(pid) do
    Agent.get(pid, fn site_map ->
      site_map
    end)
  end

  # def get_vertices(pid) do
  #   Agent.get(pid, fn site_map ->
  #     Graph.vertices(site_map)
  #   end)
  # end

  # def vertex_edges(pid, v) do
  #   Agent.get(pid, fn site_map ->
  #     Graph.edges(site_map, v)
  #   end)
  # end
end
