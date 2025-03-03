defmodule Server do
  use Application

  def start(_type, _args) do
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  def listen() do
    # Since the tester restarts your program quite often, setting SO_REUSEADDR
    # ensures that we don't run into 'Address already in use' errors
    {:ok, socket} = :gen_tcp.listen(4221, [:binary, active: false, reuseaddr: true])
    accept_loop(socket)
  end

  defp accept_loop(listening_socket) do
    {:ok, client} = :gen_tcp.accept(listening_socket)

    spawn(fn -> serve(client) end)
    accept_loop(listening_socket)
  end

  defp serve(client) do
    {:ok, packet} = :gen_tcp.recv(client, 0)

    try do
      response = handle_request_packet(packet)
      :gen_tcp.send(client, response)
      :gen_tcp.close(client)
    catch
      _ ->
        response = Response.internal_server_error() |> Response.to_string()
        :gen_tcp.send(client, response)
        :gen_tcp.close(client)
    end
  end

  defp handle_request_packet(packet) do
    request = Request.parse(packet)

    Router.route(request)
    |> Response.encode_body(request.headers)
    |> Response.to_string()
  end
end

defmodule CLI do
  @default_dir "/tmp/"

  def main(args) do
    {parsed_options, _, _} = OptionParser.parse(args, strict: [directory: :string])
    directory = Keyword.get(parsed_options, :directory, @default_dir)
    Application.put_env(:codecrafters_http_server, :directory, directory)

    # Start the Server application
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)

    # Run forever
    Process.sleep(:infinity)
  end
end
