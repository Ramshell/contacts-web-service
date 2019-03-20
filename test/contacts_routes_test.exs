defmodule Contacts.RouterTest do
  @moduledoc false

  use ExUnit.Case
  use Plug.Test

  setup do
    # Ensure the database is checkouted
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Contacts.Repo)

    {:ok, body} = Poison.encode(%{name: "FirstName", last_name: "LastName", email: "email@sh.com", phone_number: "1234"})
    %{body: body, opts: Contacts.Router.init([])}
  end

  test "GET '/' returns 404", %{opts: opts} do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "GET '/contacts' returns 200 and gets no contacts", %{opts: opts} do
    # Create a test connection
    conn = conn(:get, "/contacts")

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[]"
  end

  test "POST '/contacts' returns 201 and creates the contact", %{body: body, opts: opts} do
    # Create a test connection
    conn = conn(:post, "/contacts", body)

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    conn2 = conn(:get, "/contacts")

    # Invoke the plug
    conn2 = Contacts.Router.call(conn2, opts)

    # Assert the response and status
    assert conn2.state == :sent
    assert conn2.status == 200
    assert conn2.resp_body == "[#{body}]"
  end

  test "GET '/contacts/:lastname' returns 200 and gets the correct contact", %{opts: opts} do

    expected_contact = %Contacts.Contact{last_name: "Ruffus"}
    Contacts.Repo.insert(expected_contact)
    {:ok, expected_string_contact} = Poison.encode(expected_contact)

    # Create a test connection
    conn = conn(:get, "/contacts/Ruffus")

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == expected_string_contact
  end

  test "DELETE '/contacts/:lastname' returns 200 and actually deletes it", %{opts: opts} do

    expected_contact = %Contacts.Contact{last_name: "Ruffus"}
    Contacts.Repo.insert(expected_contact)
    {:ok, expected_string_contact} = Poison.encode(expected_contact)

    # Create a test connection
    conn = conn(:delete, "/contacts/Ruffus")

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    
    conn2 = conn(:get, "/contacts/Ruffus")

    # Invoke the plug
    conn2 = Contacts.Router.call(conn2, opts)

    # Assert Ruffus is no longer a contact
    assert conn2.state == :sent
    assert conn2.status == 404
  end
end
