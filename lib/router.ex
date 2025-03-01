defmodule Router do
  alias Response
  alias Echo

  def route(request) do
    IO.inspect(request)

    cond do
      request.path == "/" ->
        Response.ok()

      request.path == "/user-agent" ->
        Response.ok_with_body(request.user_agent)

      String.starts_with?(request.path, "/echo") ->
        Response.ok_with_body(Echo.get_body(request.path))

      true ->
        Response.not_found()
    end
  end
end
