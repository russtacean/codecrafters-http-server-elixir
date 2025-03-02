defmodule Response do
  alias Response.Headers
  alias Response.Body
  defstruct [:status_code, :headers, :body]

  @crlf "\r\n"

  # defaults
  @protocol "HTTP/1.1"
  @content_type "text/plain"

  # Response codes
  @ok 200
  @created 201
  @not_found 404
  @ise 500

  def response(status_code) when is_number(status_code) do
    build_response(status_code)
  end

  def response(status_code, body, content_type \\ @content_type) do
    build_response(status_code, body, content_type)
  end

  def to_string(response) do
    status_line = build_status_line(response.status_code)
    headers_string = Headers.to_string(response.headers)
    "#{status_line}#{@crlf}#{headers_string}#{@crlf}#{response.body.payload}"
  end

  # 2XX Codes
  def ok() do
    response(@ok)
  end

  def ok(body, content_type \\ @content_type) do
    response(@ok, body, content_type)
  end

  def created() do
    response(@created)
  end

  # 4XX Codes
  def not_found() do
    response(@not_found)
  end

  # 5XX Codes
  def internal_server_error() do
    response(@ise)
  end

  def encode_body(response, accepted_encoding) do
    body = Body.encode_body(response.body, accepted_encoding)
    headers = Headers.from_body(body)

    %__MODULE__{
      status_code: response.status_code,
      headers: headers,
      body: body
    }
  end

  defp build_response(status_code) when is_number(status_code) do
    headers = Headers.empty_headers()
    body = Body.empty_body()
    %__MODULE__{status_code: status_code, headers: headers, body: body}
  end

  defp build_response(status_code, body, content_type) do
    body = Body.build_body(body, content_type)
    headers = Headers.from_body(body)

    %__MODULE__{status_code: status_code, headers: headers, body: body}
  end

  defp build_status_line(status_code) do
    status_explanation =
      cond do
        status_code == @ok -> "OK"
        status_code == @created -> "Created"
        status_code == @not_found -> "Not Found"
        status_code == @ise -> "Internal Server Error"
      end

    "#{@protocol} #{status_code} #{status_explanation}"
  end
end
