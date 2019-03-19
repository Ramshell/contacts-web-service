defmodule ContactsTest do
  use ExUnit.Case
  doctest Contacts

  test "greets the world" do
    assert Contacts.hello() == :world
  end
end
