defmodule Echo do
  def get_body(path) do
    String.split(path, "/") |> Enum.at(2)
  end
end
