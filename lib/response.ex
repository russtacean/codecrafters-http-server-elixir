defmodule Response do
  @crlf "\r\n"
  @protocol "HTTP/1.1"
  @content_type "text/plain"
  @ok "200 OK"
  @not_found "404 Not Found"

  def ok do
    build(:ok)
  end

  def ok_with_body(body) do
    build_with_body(:ok, body)
  end

  def not_found do
    build(:not_found)
  end

  def build(status_code) do
    status_line = build_status_line(status_code)
    "#{status_line}#{@crlf}#{@crlf}"
  end

  def build_with_body(status_code, body) do
    status_line = build_status_line(status_code)
    headers = build_headers(body)
    "#{status_line}#{@crlf}#{headers}#{@crlf}#{body}"
  end

  defp build_status_line(status_code) do
    response =
      cond do
        status_code == :ok -> @ok
        status_code == :not_found -> @not_found
      end

    "#{@protocol} #{response}"
  end

  defp build_headers(body) do
    content_type = content_type(body)
    content_length = content_length(body)
    headers = "#{content_type}#{content_length}"
    if String.ends_with?(headers, @crlf), do: headers, else: "#{headers}#{@crlf}"
  end

  defp content_type(body) do
    if String.length(body) > 0, do: "Content-Type: #{@content_type}#{@crlf}", else: ""
  end

  defp content_length(body) do
    if String.length(body) > 0, do: "Content-Length: #{byte_size(body)}#{@crlf}", else: ""
  end
end
