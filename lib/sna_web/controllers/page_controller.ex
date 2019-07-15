defmodule SnaWeb.PageController do
  use SnaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
