defmodule Response.Headers do
  defstruct [:content_length, :content_encoding, :content_type]
  @crlf "\r\n"

  def empty_headers do
    %__MODULE__{
      content_encoding: "",
      content_length: "",
      content_type: ""
    }
  end

  def from_body(body) do
    %__MODULE__{
      content_encoding: content_encoding(body.content_encoding),
      content_length: content_length(body.payload),
      content_type: content_type(body.content_type)
    }
  end

  def to_string(headers) do
    header_string = "#{headers.content_encoding}#{headers.content_type}#{headers.content_length}"

    if String.ends_with?(header_string, @crlf),
      do: header_string,
      else: "#{header_string}#{@crlf}"
  end

  defp content_encoding(encoding) do
    if encoding, do: "Content-Encoding: #{encoding}#{@crlf}", else: ""
  end

  defp content_length(payload) do
    "Content-Length: #{byte_size(payload)}#{@crlf}"
  end

  defp content_type(content_type) do
    "Content-Type: #{content_type}#{@crlf}"
  end
end
