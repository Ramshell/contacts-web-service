FROM elixir:1.8

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .
COPY run.sh .

RUN rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force

RUN mix deps.get

ENTRYPOINT [ "sh", "./run.sh" ]