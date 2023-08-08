#!/bin/bash
# Valiot App image initialization script

# CONFIGURATION ----------------------------------------------------------------

# If echo handles -e option, overrides the command
if [ "$(echo -e)" == "" ]; then echo() { command echo -e "$@"; } fi

# Prints service script name with arguments detail
if [ $# -gt 0 ]; then echo "[$HOSTNAME]$0($#): $@"; fi

# FUNCTIONS --------------------------------------------------------------------

# failure()
  # Prints error and spects input prompt for continue or cancel
failure() {
  echo "🛑  \x1B[1m\x1B[38;5;1mFailure\x1B[0m"
  read -n 1 -p $'Should continue? [y/N] ' INPUT
  if [ "$INPUT" != "y" ] ; then
    exit 1
  fi
}

# SCRIPT -----------------------------------------------------------------------

if [ $# -gt 0 ] ; then
  if   [ "$1" == "dev" ] ; then
    shift
    export MIX_ENV=dev \
    && mix ecto.create \
    && mix phx.server

  elif [ "$1" == "iex" ] ; then
    shift
    export MIX_ENV=dev \
    && mix ecto.create \
    && iex -S mix phx.server

  elif [ "$1" == "test" ] ; then
    shift
    export MIX_ENV=test \
    && mix ecto.create \
    && mix test $@

  elif [ "$1" == "coverage" ] ; then
    shift
    export MIX_ENV=test \
    && mix coveralls.html --trace --seed 0
    export MIX_ENV=dev \
    && mix phx.server

  elif [ "$1" == "prod" ] ; then
    shift
    export MIX_ENV=prod \
    && mix ecto.create \
    && mix phx.server

  elif [ "$1" == "release" ] ; then
    shift
    export MIX_ENV=prod \
    && mix ecto.create \
    && mix release \
    && _build/prod/rel/valiot_app/bin/valiot_app start

  elif [ "$1" == "run" ] ; then
    shift
    eval $@

    read -n 1 -p "Press any key to stop service and remove container..."
    exit 0

  elif [ "$1" == "setup" ] ; then
    export MIX_ENV=$2 \
    && mix ecto.drop --force --force-drop \
    && mix ecto.create \
    && export SCHEMA_FILE=schema.graphql \
    && mix compile --force \
    && mix valiot.gen.api "schema.graphql" \
    && mix ecto.migrate \
    && export SCHEMA_FILE=schemav2.graphql \
    && mix compile --force \
    && mix valiot.update.api "schema.graphql" "schemav2.graphql" \
    && mix valiot.gen.uniques \
    && mix ecto.migrate \
    && echo "Success! \x1B[1mValiot App\x1B[0m database has been configured for \"$2\" environment." \
    || { failure; }
  else
    echo "Invalid arguments."
    failure
  fi

# No arguments (Default) =====================================================
else
  export PATH="_build/prod/rel/valiot_app/bin/valiot_app"

  if [ -f $DISTILLERY_PATH ]; then
    $PATH foreground
  else
    $PATH start
  fi
fi
