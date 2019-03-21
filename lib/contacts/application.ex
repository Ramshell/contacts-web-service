defmodule Contacts.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    {:ok, [port: port]} = config()

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Contacts.Router, options: [port: port]),
      Contacts.Repo,
      worker(Contacts.Scheduler, [])
    ]

    opts = [strategy: :one_for_one, name: Contacts.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp config, do: Application.fetch_env(:contacts_service, __MODULE__)
end
