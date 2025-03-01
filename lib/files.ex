defmodule Files do
  @file_content_type "application/octet-stream"

  def get_file(request) do
    file_path = get_file_path(request.path)

    case File.read(file_path) do
      {:ok, contents} -> Response.ok_with_body(contents, @file_content_type)
      {:error, _reason} -> Response.not_found()
    end
  end

  defp get_file_path(request_path) do
    # request_path is in the format "/files/<sub_dir>/<file>", so ignore the split from before root and for files path
    requested_sub_dir =
      request_path
      |> String.split("/", parts: 3)
      |> Enum.at(2)

    app_directory = Application.get_env(:codecrafters_http_server, :directory)
    Path.join(app_directory, requested_sub_dir)
  end
end
