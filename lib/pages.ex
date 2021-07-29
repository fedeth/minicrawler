defmodule Pages do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def add(pid, page_data) do
    Agent.update(
      pid,
      fn pages ->
        Map.put_new(pages, page_data.name, page_data)
      end
    )
  end

  def has_key?(pid, key) do
    Agent.get(pid, fn pages ->
      Map.has_key?(pages, key)
    end)
  end

  def get(pid, key) do
    Agent.get(pid, fn pages ->
      Map.get(pages, key)
    end)
  end

  def get_all(pid) do
    Agent.get(pid, fn pages -> pages end)
  end
end
