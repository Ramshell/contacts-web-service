use Mix.Config

config :contacts_service, Contacts.Application, port: 4000

config :contacts_service, Contacts.Scheduler,
  jobs: [
    # Every 10 minutes
    {"*/1 * * * *",   {Contacts.Repo, :delete_unactives, []}}
  ]

import_config "#{Mix.env()}.exs"