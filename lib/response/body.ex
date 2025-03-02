defmodule Response.Body do
  defstruct([:payload, :content_type, :content_encoding])
  @gzip "gzip"

  def build_body(payload, content_type \\ "text/plain") do
    %__MODULE__{
      payload: payload,
      content_type: content_type,
      content_encoding: nil
    }
  end

  def empty_body do
    %__MODULE__{
      payload: "",
      content_type: "text/plain",
      content_encoding: nil
    }
  end

  def encode_body(response_body, request_headers) do
    is_gzip =
      request_headers.accept_encoding
      |> Enum.any?(fn encoding -> encoding == @gzip end)

    content_encoding =
      if is_gzip, do: @gzip, else: nil

    %__MODULE__{
      payload: encode_payload(response_body.payload, is_gzip),
      content_type: response_body.content_type,
      content_encoding: content_encoding
    }
  end

  defp encode_payload(payload, is_gzip) do
    if is_gzip do
      :zlib.compress(payload)
    else
      payload
    end
  end
end
