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
    contacts = Contacts.Contact |> Contacts.Repo.all
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(200, Poison.encode!(contacts))
  end

  post "/contacts" do
    {:ok, body, _conn} = read_body(conn)
    changeset = Contacts.Contact.changeset(%Contacts.Contact{}, Poison.decode!(body))
    {:ok, result} = Contacts.Repo.insert(changeset)
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(201, Poison.encode!(result))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
