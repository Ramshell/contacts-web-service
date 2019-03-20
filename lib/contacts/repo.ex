defmodule Contacts.Repo do
  use Ecto.Repo,
    otp_app: :contacts_service,
    adapter: Ecto.Adapters.Postgres
    require Ecto.Query

    def get_all() do
      Contacts.Contact
      |> Ecto.Query.where(active: true)
      |> Ecto.Query.order_by(:last_name)
      |> all
    end

    @spec get_by_last_name(String.t()) :: Contacts.Contact | nil
    def get_by_last_name(last_name) do
      Contacts.Contact
      |> Ecto.Query.where(active: true)
      |> get(last_name)
    end

    @spec update_with_diff(Contacts.Contact, map()) :: {atom, Contacts.Contact}
    def update_with_diff(resource, diff) do
      changeset = Contacts.Contact.changeset(resource, diff)
      insert(changeset)
    end

    @spec delete_by_last_name(String.t()) :: {atom, Contacts.Contact}
    def delete_by_last_name(last_name) do
      contact = get_by_last_name(last_name)
      updated_changeset = Contacts.Contact.changeset(contact, %{active: false})
      Contacts.Repo.update(updated_changeset)
    end
end
