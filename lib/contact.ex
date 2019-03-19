defmodule Contact do
  require Record
  Record.defrecord(:contact, name: "", last_name: "", email: "", phone_number: "")

  @type contact ::
          record(:contact,
            name: String.t(),
            last_name: String.t(),
            email: String.t(),
            phone_number: String.t()
          )
end
