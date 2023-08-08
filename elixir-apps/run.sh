#!/bin/bash
# Elixir Apps images initialization script

# CONFIGURATION ----------------------------------------------------------------

  # Location path of the volume shared file in the container.
  export SETUP_PROPERTIES_PATH="../"
  export SIGNATURE_MESSAGE="service setup result"
  export ENUM_INTROSPECTION_QUERY="SELECT unnest(enum_range(NULL::relation_type))::text AS relation_types"
  
  # Prints service script name with arguments detail
  if [ $# -gt 0 ]; then echo "[$HOSTNAME]$0($#): $@"; fi

  # If echo handles -e option, overrides the command
  if [ "$(echo -e)" == "" ]; then echo() { command echo -e "$@"; } fi

# FUNCTIONS --------------------------------------------------------------------

  # failure()
    # Prints error and spects input prompt for continue or cancel
  failure() {
    echo "🛑  \x1B[1m\x1B[38;5;1mFailure\x1B[0m"
    read -n 1 -p $'Should continue? [y/N] ' INPUT
    if [ "$INPUT" != "y" ]; then
      exit 1
    fi
    echo ""
  }

  # ecto_reset()
    # Custom version of `mix ecto.reset` for production enviroment
  ecto_reset() {
    export MIX_ENV=prod \
    && mix ecto.drop --force --force-drop \
    && mix ecto.create \
    && (
      mix ecto.migrate \
      || for FILE in ./priv/repo/migrations/*
      do
        mix ecto.migrate --step 1 \
        || { failure && rm $FILE; }
      done
    )
  }

# SCRIPT -----------------------------------------------------------------------

# More than 1 argument workflows =============================================
if [ $# -gt 0 ]; then
  if   [ "$1" == "auth.setup" ]; then
    ecto_reset \
    && SETUP_PROPERTIES_FILE=$2 \
    && TOKEN_TTL=$3 \
    && mix run -e "
      alias ValiotApp.{Repo, Api}

      {:ok, %{
        id: app_token_id,
        token: app_token
      }} = Api.create_token($TOKEN_TTL)

      {:ok, %{
        id: worker_token_id,
        token: worker_token
      }} = Api.create_token($TOKEN_TTL)
      
      :ok = Enum.each(
        [
          :permission,
          :token,
        ],
        fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: app_token_id,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end
      )

      {:ok, %{rows: rows}} = Repo.query(\"$ENUM_INTROSPECTION_QUERY\")
      
      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            # DANGER: Hardcoding! 
            # This id will be generated for super-admin user token, it is done
            # this way to avoid starting the container again once the
            # super-admin user its created.
            token_id: 3,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)

      :ok = File.write!(
        \"$SETUP_PROPERTIES_PATH$SETUP_PROPERTIES_FILE\",
        \"\"\"
        # $SETUP_PROPERTIES_FILE
        # Auth $SIGNATURE_MESSAGE
        APP_TOKEN_ID=\"#{app_token_id}\"
        APP_TOKEN=\"#{app_token}\"
        WORKER_TOKEN_ID=\"#{worker_token_id}\"
        WORKER_TOKEN=\"#{worker_token}\"
        \"\"\"
      )
      " \
    || failure

  elif [ "$1" == "user.setup" ]; then
    ecto_reset \
    && SETUP_PROPERTIES_FILE=$2 \
    && TOKEN_ID=$3 \
    && EMAIL="$4" \
    && PASS=$5 \
    && NAME=$6 \
    && LAST_NAME=$7 \
    && WORKER_TOKEN_ID=$8 \
    && mix run -e "
      alias ValiotApp.{Repo, Api}
      alias ValiotAppWeb.TokenHelper

      :ok = Enum.each(
        [
          :permission,
          :user
        ],
        fn(relation) ->
          Repo.insert!(%ValiotApp.Api.Permission{
            token_id: $TOKEN_ID,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end
      )

      {:ok, %{
        email: email,
        password: password,
        name: name,
        last_name: last_name,
        token_id: token_id
      }} =
        Api.create_user(%{
          email: \"$EMAIL\",
          password: \"$PASS\",
          name: \"$NAME\",
          last_name: \"$LAST_NAME\"
        }, $TOKEN_ID)

      {:ok, %{\"token\" => token}} = TokenHelper.update_token(token_id)

      {:ok, %{rows: rows}} = Repo.query(\"$ENUM_INTROSPECTION_QUERY\")
      
      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: token_id,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)
      
      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: $WORKER_TOKEN_ID,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)
      
      :ok = File.write!(
        \"$SETUP_PROPERTIES_PATH$SETUP_PROPERTIES_FILE\",
        \"\"\"
        # User $SIGNATURE_MESSAGE
        SUPER_USER_EMAIL=\"#{email}\"
        SUPER_USER_PASS=\"#{password}\"
        SUPER_USER_NAME=\"#{name}\"
        SUPER_USER_LAST_NAME=\"#{last_name}\"
        SUPER_USER_TOKEN_ID=\"#{token_id}\"
        SUPER_USER_TOKEN=\"#{token}\"
        \"\"\",
        [:append]
      )
      " \
    || failure

  elif [ "$1" == "jobs.setup" ]; then
    ecto_reset \
    && SETUP_PROPERTIES_FILE=$2 \
    && APP_TOKEN_ID=$3 \
    && WORKER_TOKEN_ID=$4 \
    && WORKER_NAME=$5 \
    && SUPER_USER_TOKEN_ID=$6 \
    && mix run -e "
      alias ValiotApp.{Repo, Api}

      Repo.insert!(%Api.Permission{
        token_id: $APP_TOKEN_ID,
        relation: :permission,
        read: true,
        create: true,
        update: true,
        delete: true
      })

      %{
        name: worker_name,
        code: worker_code
      } = Repo.insert!(%Api.Worker{
        name: \"$WORKER_NAME\",
        code: \"$WORKER_NAME\"
      })
      
      {:ok, %{rows: rows}} = Repo.query(\"$ENUM_INTROSPECTION_QUERY\")
      
      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: $SUPER_USER_TOKEN_ID,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)

      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: $WORKER_TOKEN_ID,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)

      :ok = File.write!(
        \"$SETUP_PROPERTIES_PATH$SETUP_PROPERTIES_FILE\",
        \"\"\"
        # Worker $SIGNATURE_MESSAGE
        WORKER_NAME=\"#{worker_name}\"
        WORKER_CODE=\"#{worker_code}\"
        \"\"\",
        [:append]
      )
      " \
    || failure

  elif [ "$1" == "setup" ]; then
    ecto_reset \
    && TOKEN_ID=$2 \
    && SUPER_USER_TOKEN_ID=$3 \
    && WORKER_TOKEN_ID=$4 \
    && mix run -e "
      alias ValiotApp.{Repo, Api}

      Repo.insert!(%Api.Permission{
        token_id: $TOKEN_ID,
        relation: :permission,
        read: true,
        create: true,
        update: true,
        delete: true
      })
      
      {:ok, %{rows: rows}} = Repo.query(\"$ENUM_INTROSPECTION_QUERY\")
      
      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: $SUPER_USER_TOKEN_ID,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)
      
      :ok =
        rows
        |> Enum.map(fn([relation_type]) -> String.to_atom(relation_type) end)
        |> Enum.each(fn(relation) ->
          Repo.insert!(%Api.Permission{
            token_id: $WORKER_TOKEN_ID,
            relation: relation,
            read: true,
            create: true,
            update: true,
            delete: true
          })
        end)
      " \
    || failure

  elif [ "$1" == "run" ]; then
    shift
    eval $@
    read -n 1 -p "Press any key to stop service and remove container..."
    exit 0

  else
    echo "Invalid arguments."
    failure
  fi

# No arguments (Default) =====================================================
else
  export DISTILLERY_PATH="_build/prod/rel/valiot_app/bin/valiot_app"
  RELEASE=$( echo $HOSTNAME | sed 's/-/_/g' ) && \
  export NATIVE_PATH="_build/prod/rel/$RELEASE/bin/$RELEASE"

  if [ -f $DISTILLERY_PATH ]; then
    $DISTILLERY_PATH foreground
  else
    $NATIVE_PATH start
  fi
fi
