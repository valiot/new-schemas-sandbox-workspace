defmodule WspaceUIWeb.PageController do
  @moduledoc false

  use WspaceUIWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
