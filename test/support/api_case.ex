defmodule SnaWeb.ApiCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      def json_conn(conn) do
        conn
          |> put_req_header("accept", "application/json")
      end

      def json_dispatch(conn, method, path, body) do
        conn
          |> json_conn()
          |> put_req_header("content-type", "application/json")
          |> dispatch(@endpoint, method, path, Jason.encode!(body))
      end
    end
  end
end
