defmodule Contacts.Router do
  @moduledoc """
  Provides the basic routing of the contacts app.
  """
  use Plug.Router

  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  @content_type "application/json"

  get "/contacts" do
    contacts = Contacts.Repo.get_all()
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(200, Poison.encode!(contacts))
  end

  post "/contacts" do
    {:ok, body, _conn} = read_body(conn)
    {:ok, result} = Contacts.Repo.update_with_diff(%Contacts.Contact{}, Poison.decode!(body))
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(201, Poison.encode!(result))
  end

  get "/contacts/:last_name" do
    case Contacts.Repo.get_by_last_name(last_name) do
      nil ->
        conn
        |> put_resp_content_type(@content_type)
        |> send_resp(404, "not found")
      contact ->
        conn
        |> put_resp_content_type(@content_type)
        |> send_resp(200, Poison.encode!(contact))
    end
  end

  delete "/contacts/:last_name" do
    {:ok, _updated} = Contacts.Repo.delete_by_last_name(last_name)
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(204, "")
  end

  patch "/contacts/:last_name" do
    {:ok, body, _conn} = read_body(conn)
    case Contacts.Repo.get_by_last_name(last_name) do
      nil ->
        conn
        |> put_resp_content_type(@content_type)
        |> send_resp(404, "not found")
      contact ->
        {:ok, result} = Contacts.Repo.update_with_diff(contact, Poison.decode!(body))
        conn
        |> put_resp_content_type(@content_type)
        |> send_resp(204, Poison.encode!(result))
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
