defmodule Contacts.Contact do
    @moduledoc """
    Provides abstraction for the contact resource
    """

    use Ecto.Schema

    @primary_key {:last_name, :string, autogenerate: false}
  
    @derive {Poison.Encoder, only: [:name, :last_name, :email, :phone_number]}
    schema "contacts" do
      field :name, :string
      field :email, :string
      field :phone_number, :string
      field :active, :boolean, default: true
    end

    def changeset(contact, params \\ %{}) do
        contact
        |> Ecto.Changeset.cast(params, [:name, :last_name, :email, :phone_number, :active])
        |> Ecto.Changeset.validate_required([:last_name])
    end
  end