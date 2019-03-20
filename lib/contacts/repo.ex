defmodule Contacts.Repo do
  use Ecto.Repo,
    otp_app: :contacts_service,
    adapter: Ecto.Adapters.Postgres

    @spec get_by_last_name(String.t()) :: Contacts.Contact
    def get_by_last_name(last_name) do
      Contacts.Contact |> get(last_name)
    end
end
