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

  test "GET '/contacts' returns the contacts ordered by last_name", %{opts: opts} do
    to_insert = [
      %Contacts.Contact{last_name: "Ruffus"},
      %Contacts.Contact{last_name: "Buffus"},
      %Contacts.Contact{last_name: "Auri"}
    ]

    # Insert the contacts into the db
    Enum.each to_insert, fn x ->
      Contacts.Repo.insert(x)
    end

    expected_contacts = [
      %Contacts.Contact{last_name: "Auri"},
      %Contacts.Contact{last_name: "Buffus"},
      %Contacts.Contact{last_name: "Ruffus"}
    ]
    {:ok, expected_contacts_string} = Poison.encode(expected_contacts)

    # Create a test connection
    conn = conn(:get, "/contacts")

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == expected_contacts_string
  end

  test "POST '/contacts' returns 201 and creates the contact", %{opts: opts} do
    # Create a test connection
    {:ok, malformed_body} = Poison.encode(%{name: "FirstName", email: "email@sh.com", phone_number: "1234"})
    conn = conn(:post, "/contacts", malformed_body)

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 400

    conn2 = conn(:get, "/contacts")

    # Invoke the plug
    conn2 = Contacts.Router.call(conn2, opts)

    # Assert the response and status
    assert conn2.state == :sent
    assert conn2.status == 200
    assert conn2.resp_body == "[]"
  end

  test "POST '/contacts' returns 400 if the body is not correctly formed", %{body: body, opts: opts} do
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

    # Create a test connection
    conn = conn(:delete, "/contacts/Ruffus")

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 204
    
    conn2 = conn(:get, "/contacts/Ruffus")

    # Invoke the plug
    conn2 = Contacts.Router.call(conn2, opts)

    # Assert Ruffus is no longer a contact
    assert conn2.state == :sent
    assert conn2.status == 404
  end

  test "PATCH '/contacts/:lastname' returns 204 and actually updates it", %{opts: opts} do

    contact_to_insert = %Contacts.Contact{last_name: "Ruffus"}
    Contacts.Repo.insert(contact_to_insert)

    {:ok, update_delta} = Poison.encode(%{name: "Martin"})

    expected_contact = %Contacts.Contact{last_name: "Ruffus", name: "Martin"}
    {:ok, expected_contact_string} = Poison.encode(expected_contact)

    # Create a test connection
    conn = conn(:patch, "/contacts/Ruffus", update_delta)

    # Invoke the plug
    conn = Contacts.Router.call(conn, opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == expected_contact_string
  end
end
