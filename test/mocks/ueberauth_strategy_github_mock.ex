defmodule SnaWeb.UeberauthStrategyGithubMock do

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    case code do
      "ok" ->
        conn
          |> Plug.Conn.assign(:ueberauth_auth, %{
            credentials: %{
              token:      "valid-token",
              secret:     "valid-secret",
              expires_at: 42,
            }
          })
      "error" ->
        conn
          |> Plug.Conn.assign(:ueberauth_failure, :error_object)
    end
  end

  def handle_cleanup!(conn) do
    conn
  end

end
