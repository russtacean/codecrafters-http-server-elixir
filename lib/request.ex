defmodule Request do
  defstruct [:method, :path, :user_agent, :body]

  @crlf "\r\n"

  def parse(packet) do
    [request_line | rest] = String.split(packet, @crlf)
    [method, path, _protocol] = String.split(request_line, " ")

    {body, raw_headers} = List.pop_at(rest, -1)
    headers_map = parse_headers(raw_headers)
    user_agent = Map.get(headers_map, "User-Agent")

    %__MODULE__{body: body, method: method, path: path, user_agent: user_agent}
  end

  defp parse_headers(raw_headers) do
    # Ignore empty string from last CRLF that indicates end of headers
    {_finalcrlf, headers} = List.pop_at(raw_headers, -1)

    Enum.reduce(headers, %{}, fn header, acc ->
      [key, value] = String.split(header, ": ")
      Map.put(acc, key, value)
    end)
  end
end
