defmodule Contacts.RouterTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test

  @opts Contacts.Router.init([])

  test "get '/' returns 404" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = Contacts.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "get '/contacts' returns 200 and gets no contacts" do
    # Create a test connection
    conn = conn(:get, "/contacts")

    # Invoke the plug
    conn = Contacts.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[]"
  end

  setup do
    {:ok, body} = Poison.encode(%{name: "FirstName", last_name: "LastName", email: "email@sh.com", phone_number: "1234"})
    %{body: body}  
  end

  test "post '/contacts' returns 201 and creates the contact", %{body: body} do
    # Create a test connection
    conn = conn(:post, "/contacts", body)

    # Invoke the plug
    conn = Contacts.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    conn2 = conn(:get, "/contacts")

    # Invoke the plug
    conn2 = Contacts.Router.call(conn, @opts)

    # Assert the response and status
    assert conn2.state == :sent
    assert conn2.status == 200
    assert conn2.resp_body == "[#{body}]"
  end
end