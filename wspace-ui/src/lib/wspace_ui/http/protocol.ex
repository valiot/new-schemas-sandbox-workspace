defmodule WspaceUI.HTTP.Protocol do
  @moduledoc """
  System tools used as helpers ni various modules around the application.
  """

  alias Phoenix.Controller
  alias Plug.Conn

  @doc """
  Controllers helper. It returns a response for the active plug session.

  It will set the corresponding `content_type` to the response according to the `resp` term. It might be `application/json`, `text/html` or none.

  If the given `code` is 204 will send a response without content regardless of whether a `resp` term has been given or not.

  If the given `resp` is an invalid changeset it will traverse the errors into a map.

  If no `resp` were given and the given `code` is between range 400-405, it will set a default message.
    * 400: `"Bad request"`.
    * 401: `"Unauthorized"`.
    * 402: `"Payment Required"`.
    * 403: `"Forbidden"`.
    * 404: `"Does not exist"`.
    * 405: `"Method Not Allowed"`.

  ## Example
      iex> Support.Tools.respond(%Plug.Conn{}, 200)
      # returns no content
  """
  @spec respond(
          conn :: Plug.Conn.t(),
          code :: 100..599,
          resp :: nil | Changeset.t() | map | String.t()
        ) :: none
  def respond(conn, code, resp \\ nil)

  def respond(conn, code, nil = resp), do: respond(conn, code, resp, :none)

  def respond(conn, code, resp) when is_map(resp) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> respond(code, resp, :map)
  end

  def respond(conn, code, resp) when is_binary(resp) do
    conn
    |> Conn.put_resp_content_type("text/html")
    |> respond(code, resp, :binary)
  end

  # === Private ================================================================

  defp respond(%Conn{} = conn, code, resp, type)
  when code >= 100 and code <= 599 do
    conn = Conn.put_status(conn, code)

    [Integer.digits(code), type]
    |> case do
      # Default no content response
      [[2, 0, 4], _] ->
        conn
        |> Conn.delete_resp_header("content-type")
        |> Conn.send_resp(code, "")

      # Default responses when no content given
      [[4, 0, 0], :none] -> respond(conn, code, "❌ Bad request")
      [[4, 0, 1], :none] -> respond(conn, code, "🚷 Unauthorized")
      [[4, 0, 2], :none] -> respond(conn, code, "🪙 Payment Required")
      [[4, 0, 3], :none] -> respond(conn, code, "🚫 Forbidden")
      [[4, 0, 4], :none] -> respond(conn, code, "🔍 Does not exist")
      [[4, 0, 5], :none] -> respond(conn, code, "⛔ Method Not Allowed")

      # Custom responses
      [[_, _, _], :none] ->
        Conn.send_resp(conn, code, "")

      [[_, _, _], :binary] ->
        Conn.send_resp(conn, code, resp)

      [[_, _, _], :map] ->
        Controller.json(conn, resp)
    end
  end
end
