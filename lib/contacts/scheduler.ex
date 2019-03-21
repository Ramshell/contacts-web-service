defmodule Contacts.Scheduler do
    @moduledoc false
    use Quantum.Scheduler,
      otp_app: :contacts_service
  end