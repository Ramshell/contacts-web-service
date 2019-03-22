FROM elixir:1.8-alpine

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

RUN rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

ENTRYPOINT [ "mix", "run", "--no-halt" ]