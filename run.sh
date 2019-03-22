set -e

# Prepare Dialyzer if the project has Dialyxer set up
if mix help dialyzer >/dev/null 2>&1
then
  echo "\nFound Dialyxer: Setting up PLT..."
  mix do deps.compile, dialyzer --plt
else
  echo "\nNo Dialyxer config: Skipping setup..."
fi

# Potentially Set up the database
mix ecto.create
mix ecto.migrate

echo "\nTesting the installation..."
# "Proove" that install was successful by running the tests
mix test

echo "\n Starting web server..."
# Start the web server
mix run --no-halt