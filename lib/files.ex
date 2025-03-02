defmodule Files do
  @file_content_type "application/octet-stream"

  def get_file(request) do
    file_path = get_file_path(request.path)

    case File.read(file_path) do
      {:ok, contents} -> Response.ok(contents, @file_content_type)
      {:error, _reason} -> Response.not_found()
    end
  end

  def write_file(request) do
    file_path = get_file_path(request.path)
    body = request.body

    case File.write(file_path, body) do
      :ok -> Response.created()
      _ -> Response.internal_server_error()
    end
  end

  defp get_file_path(request_path) do
    sub_dir =
      Regex.named_captures(~r/\/files\/(?<subdir>.*)/, request_path)
      |> Map.get("subdir")

    app_directory = Application.get_env(:codecrafters_http_server, :directory)
    Path.join(app_directory, sub_dir)
  end
end
