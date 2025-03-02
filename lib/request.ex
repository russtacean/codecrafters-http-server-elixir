defmodule Request do
  alias Request.Headers
  defstruct [:body, :headers, :method, :path]

  @crlf "\r\n"

  def parse(packet) do
    [request_line | rest] = String.split(packet, @crlf)
    [method, path, _protocol] = String.split(request_line, " ")

    {body, raw_headers} = List.pop_at(rest, -1)
    headers = Headers.parse_headers(raw_headers)

    %__MODULE__{
      body: body,
      headers: headers,
      method: method,
      path: path
    }
  end
end
