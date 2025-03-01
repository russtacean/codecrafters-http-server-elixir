defmodule Server do
  use Application

  @crlf "\r\n"

  def start(_type, _args) do
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  def listen() do
    # Since the tester restarts your program quite often, setting SO_REUSEADDR
    # ensures that we don't run into 'Address already in use' errors
    {:ok, socket} = :gen_tcp.listen(4221, [:binary, active: false, reuseaddr: true])
    {:ok, client} = :gen_tcp.accept(socket)

    # receive all data, no length limit
    {:ok, packet} = :gen_tcp.recv(client, 0)
    [request_line | _] = String.split(packet, @crlf)
    [_method, path, _] = String.split(request_line, " ")

    is_echo = String.starts_with?(path, "/echo")
    status_line = get_status_line(path, is_echo)
    body = get_body(path, is_echo)
    headers = get_headers(body)
    response = "#{status_line}#{@crlf}#{headers}#{@crlf}#{body}"

    :gen_tcp.send(client, response)
  end

  def get_status_line(path, is_echo) do
    response_code =
      cond do
        path == "/" -> "200 OK"
        is_echo -> "200 OK"
        true -> "404 Not Found"
      end

    "HTTP/1.1 #{response_code}"
  end

  def get_body(path, is_echo) do
    if is_echo, do: String.split(path, "/") |> Enum.at(2), else: ""
  end

  def get_headers(body) do
    content_type = get_content_type(body)
    content_length = get_content_length(body)
    headers = "#{content_type}#{content_length}"
    if String.ends_with?(headers, @crlf), do: headers, else: "#{headers}#{@crlf}"
  end

  def get_content_type(body) do
    if body, do: "Content-Type: text/plain#{@crlf}", else: ""
  end

  def get_content_length(body) do
    if body, do: "Content-Length: #{byte_size(body)}#{@crlf}", else: ""
  end
end

defmodule CLI do
  def main(_args) do
    # Start the Server application
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)

    # Run forever
    Process.sleep(:infinity)
  end
end
