use Mix.Config

config :contacts_service, Contacts.Repo,
  database: "contacts_service_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :contacts_service, ecto_repos: [Contacts.Repo]