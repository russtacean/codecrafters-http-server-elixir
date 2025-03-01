defmodule Router do
  alias Response
  alias Echo

  def route(request) do
    cond do
      request.path == "/" ->
        Response.ok()

      String.starts_with?(request.path, "/echo") ->
        Echo.echo(request)

      String.starts_with?(request.path, "/files") ->
        case request.method do
          "GET" -> Files.get_file(request)
          "POST" -> Files.write_file(request)
        end

      request.path == "/user-agent" ->
        Response.ok_with_body(request.user_agent)

      true ->
        Response.not_found()
    end
  end
end
