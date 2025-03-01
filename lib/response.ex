defmodule Response do
  @crlf "\r\n"

  # defaults
  @protocol "HTTP/1.1"
  @content_type "text/plain"

  # Response codes
  @ok "200 OK"
  @not_found "404 Not Found"
  @created "201 Created"
  @ise "500 Internal Server Error"

  # 2XX Codes
  def ok do
    build(:ok)
  end

  def ok_with_body(body, content_type \\ @content_type) do
    build_with_body(:ok, body, content_type)
  end

  def created do
    build(:created)
  end

  # 4XX Codes
  def not_found do
    build(:not_found)
  end

  # 5XX Codes
  def internal_server_error do
    build(:ise)
  end

  def build(status_code) do
    status_line = build_status_line(status_code)
    "#{status_line}#{@crlf}#{@crlf}"
  end

  def build_with_body(status_code, body, content_type \\ @content_type) do
    status_line = build_status_line(status_code)
    headers = build_headers(body, content_type)
    "#{status_line}#{@crlf}#{headers}#{@crlf}#{body}"
  end

  defp build_status_line(status_code) do
    response =
      cond do
        status_code == :ok -> @ok
        status_code == :not_found -> @not_found
        status_code == :created -> @created
        status_code == :ise -> @ise
      end

    "#{@protocol} #{response}"
  end

  defp build_headers(body, requested_content_type) do
    has_body = String.length(body) > 0
    content_type = build_content_type(has_body, requested_content_type)
    content_length = content_length(has_body, body)
    headers = "#{content_type}#{content_length}"
    if String.ends_with?(headers, @crlf), do: headers, else: "#{headers}#{@crlf}"
  end

  defp build_content_type(has_body, content_type) do
    if has_body, do: "Content-Type: #{content_type}#{@crlf}", else: ""
  end

  defp content_length(has_body, body) do
    if has_body, do: "Content-Length: #{byte_size(body)}#{@crlf}", else: ""
  end
end
