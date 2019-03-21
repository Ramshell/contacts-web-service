defmodule Contacts.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :name, :string
      add :last_name, :string
      add :email, :string
      add :phone_number, :string
      add :active, :boolean, default: true
    end
  end
end
