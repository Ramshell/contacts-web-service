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
  end