defmodule Page do
  @enforce_keys [:name]
  defstruct [:name, assets: %{css: [], img: [], js: []}, links: []]
end
