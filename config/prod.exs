use Mix.Config

config :contacts_service, Contacts.Repo,
  database: System.get_env("POSTGRESQL_DATABASE"),
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRESQL_HOSTNAME"),
  page_size: System.get_env("CONTACTS_PAGE_SIZE")

config :contacts_service, ecto_repos: [Contacts.Repo]