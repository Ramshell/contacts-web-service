use Mix.Config

config :contacts_service, Contacts.Repo,
  database: "contacts_service_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :contacts_service, ecto_repos: [Contacts.Repo]