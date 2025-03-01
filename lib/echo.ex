defmodule Echo do
  defp get_body(path) do
    # Ensure we echo anything after the first two slashes (e.g. /echo/this/foo should echo "this/foo")
    String.split(path, "/", parts: 3) |> Enum.at(2)
  end

  def echo(request) do
    body = get_body(request.path)
    Response.ok_with_body(body)
  end
end
