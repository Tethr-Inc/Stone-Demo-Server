defmodule StoneDemoServer.PageController do
  use StoneDemoServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
