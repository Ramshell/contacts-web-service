defmodule Contacts.Repo do
  use Ecto.Repo,
    otp_app: :contacts_service,
    adapter: Ecto.Adapters.Postgres
    require Ecto.Query

    def get_all(page \\ 1) do
      {:ok, conf_opt} = conf()
      {p_size, _rest} = Integer.parse(conf_opt[:page_size])
      offset = p_size * (page - 1)
      Contacts.Contact
      |> Ecto.Query.where(active: true)
      |> Ecto.Query.order_by(:last_name)
      |> Ecto.Query.limit(^p_size)
      |> Ecto.Query.offset(^offset)
      |> all
    end

    @spec get_by_last_name(String.t()) :: map() | nil
    def get_by_last_name(last_name) do
      Contacts.Contact
      |> Ecto.Query.where(active: true)
      |> get(last_name)
    end

    @spec insert_resource(map()) :: {atom, map()}
    def insert_resource(resource) do
      changeset = Contacts.Contact.changeset(%Contacts.Contact{}, resource)
      insert(changeset)
    end

    @spec update_with_diff(map(), map()) :: {atom, map()}
    def update_with_diff(resource, diff) do
      changeset = Contacts.Contact.changeset(resource, diff)
      update(changeset)
    end

    @spec delete_by_last_name(String.t()) :: {atom, map()}
    def delete_by_last_name(last_name) do
      contact = get_by_last_name(last_name)
      updated_changeset = Contacts.Contact.changeset(contact, %{active: false})
      Contacts.Repo.update(updated_changeset)
    end

    @spec delete_unactives() :: {atom, any()}
    def delete_unactives do
      Enum.map (Contacts.Contact |> Ecto.Query.where(active: false) |> all), fn changeset ->
        delete(changeset)
      end
    end

    defp conf, do: Application.fetch_env(:contacts_service, __MODULE__)
end
