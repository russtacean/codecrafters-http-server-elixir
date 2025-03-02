defmodule Router do
  def route(request) do
    cond do
      request.path == "/" ->
        Response.ok()

      Regex.match?(~r/\/echo\/.*/, request.path) ->
        Regex.named_captures(~r/\/echo\/(?<echoed>.*)/, request.path)
        |> Map.get("echoed")
        |> Response.ok()

      Regex.match?(~r/\/files\/.*/, request.path) ->
        case request.method do
          "GET" -> Files.get_file(request)
          "POST" -> Files.write_file(request)
        end

      request.path == "/user-agent" ->
        Response.ok(request.headers.user_agent)

      true ->
        Response.not_found()
    end
  end
end
