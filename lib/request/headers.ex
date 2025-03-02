defmodule Request.Headers do
  defstruct [:accept_encoding, :user_agent]

  def parse_headers(raw_headers) do
    headers_map = parse_raw_headers(raw_headers)
    accepted_encoding = Map.get(headers_map, "Accept-Encoding", "")

    %__MODULE__{
      accept_encoding: String.split(accepted_encoding, ", "),
      user_agent: Map.get(headers_map, "User-Agent", "")
    }
  end

  defp parse_raw_headers(raw_headers) do
    # Ignore empty string from last CRLF that indicates end of headers
    {_finalcrlf, headers} = List.pop_at(raw_headers, -1)

    Enum.reduce(headers, %{}, fn header, acc ->
      [key, value] = String.split(header, ": ")
      Map.put(acc, key, value)
    end)
  end
end
