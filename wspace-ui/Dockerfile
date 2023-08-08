FROM elixir:1.14-slim as builder

RUN apt-get update -y \
    && apt-get install build-essential git -y \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV="prod"

COPY ./wspace-ui/src/mix.* ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir ./config
# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY ./wspace-ui/src/config/config.exs ./wspace-ui/src/config/${MIX_ENV}.exs ./config/
RUN mix deps.compile

COPY ./wspace-ui/src/priv/ ./priv/
COPY ./wspace-ui/src/lib/ ./lib/
COPY ./wspace-ui/src/assets/ ./assets/

# Extra to serve documtation
COPY ./README.md ./
COPY ./CHANGELOG.md ./
COPY ./arch_diagram.svg ./priv/static/doc/
RUN mix docs

RUN mix assets.deploy

RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY ./wspace-ui/src/config/runtime.exs ./config/

COPY ./wspace-ui/src/rel/ ./rel/
RUN mix release wspace_ui

# ------------------------------------------------------------------------------

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM elixir:1.14-slim as runner

RUN apt-get update -y \
    && apt-get install \
      curl \
      inotify-tools \
      libncurses5 \
      libstdc++6 \
      locales \
      openssl \
      -y \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/wspace_ui ./

USER nobody

RUN chmod +x /app/bin/server
CMD ["/app/bin/server"]/app
