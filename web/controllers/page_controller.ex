defmodule PhoenixTracker.PageController do
  use PhoenixTracker.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
