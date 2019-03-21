defmodule Contacts.Router do
  @moduledoc """
  Provides the basic routing of the contacts app.
  """
  use Plug.Router
  require Logger

  @content_type "application/json"

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  get "/contacts" do
    contacts = Contacts.Repo.get_all()
    api_resp conn, 200, Poison.encode!(contacts)
  end

  post "/contacts" do
    {:ok, body, _conn} = read_body(conn)
    case Contacts.Repo.update_with_diff(%Contacts.Contact{}, Poison.decode!(body)) do
      {:ok, result} ->
        api_resp conn, 201, Poison.encode!(result)
      {:error, change_set} ->
        api_resp conn, 400, Poison.encode!(error_map change_set.errors)
    end
  end

  get "/contacts/:last_name" do
    case Contacts.Repo.get_by_last_name(last_name) do
      nil ->
        api_resp conn, 404, "not found"
      contact ->
        api_resp conn, 200, Poison.encode!(contact)
    end
  end

  delete "/contacts/:last_name" do
    {:ok, _updated} = Contacts.Repo.delete_by_last_name(last_name)
    api_resp conn, 204, ""
  end

  patch "/contacts/:last_name" do
    {:ok, body, _conn} = read_body(conn)
    case Contacts.Repo.get_by_last_name(last_name) do
      nil ->
        api_resp conn, 404, "not found"
      contact ->
        {:ok, result} = Contacts.Repo.update_with_diff(contact, Poison.decode!(body))
        api_resp conn, 204, Poison.encode!(result)
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp api_resp(conn, code, result) do
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(code, result)
  end

  @spec error_map([{atom, {String.t(), any()}}]) :: map()
  defp error_map(errors) do
    Enum.reduce errors, %{}, fn error, res ->
      {field, {reason, _validations}} = error
      Map.put(res, field, reason)
    end
  end
end
