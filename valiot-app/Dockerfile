FROM ghcr.io/valiot/valiot-app:latest

# Install system packages.
# curl: docker compose healthcheck.
# inotify-tools: is for Phoenix LiveDashboard use.
# libncurses5, libstdc++6, locales and openssl: packages are Phoenix defaults.
# lsb-release, gnupg2 and wget: are required to install postgresql-14.
# postgresql-14: postgres version must match the DB version for mix ecto.dump).
RUN apt-get update -y && \
    apt-get install -y \
    curl inotify-tools libncurses5 libstdc++6 locales openssl lsb-release \
    gnupg2 wget && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# Installs postgresql-14:
# postgres version must match the database container postgres version in order 
# to run mix ecto.dump (for collapsing migrations).
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt \
    $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get -y update && apt-get -y install postgresql-14

# Composed Workspace flag.
ENV WORKSPACE=true

# Gets and compiles dependencies for all environments.
RUN MIX_ENV=dev mix do deps.get, deps.compile
RUN MIX_ENV=test mix do deps.get, deps.compile
RUN MIX_ENV=prod mix do deps.get, deps.compile

COPY ./valiot-app/*.graphql ./

# compiles the system for all environments.
RUN MIX_ENV=dev mix compile --force
RUN MIX_ENV=test mix compile --force
RUN MIX_ENV=prod mix compile --force

RUN mix docs

# VOLUME /valiot-app/priv/static/doc
# VOLUME /valiot-app/priv/static/cover

# Copies the cerftificates for ssl.
RUN mkdir -p ./priv/static/cert
COPY ./valiot-app-db/ssl/out/ ./priv/static/cert/

# Copies and makes excecutable the script to start the service.
COPY ./valiot-app/run.sh ./
RUN chmod +x run.sh

CMD ["./run.sh"]
