# FROM elixir:1.10.4 as builder

# # build step
# ARG MIX_ENV=prod
# ARG NODE_ENV=production
# ARG APP_VER=0.0.1
# ENV APP_VERSION=$APP_VER

# RUN mkdir /app
# WORKDIR /app

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
#     apt-get install -y nodejs fswatch

# # Client side
# COPY assets/package.json assets/package-lock.json ./assets/
# RUN npm install --prefix=assets

# # fix because of https://github.com/facebook/create-react-app/issues/8413
# ENV GENERATE_SOURCEMAP=false

# COPY priv priv
# COPY assets assets
# RUN npm run build --prefix=assets

# COPY mix.exs mix.lock ./
# COPY config config

# RUN mix local.hex --force && \
#     mix local.rebar --force && \
#     mix deps.get --only prod

# COPY lib lib
# RUN mix deps.compile
# RUN mix phx.digest

# WORKDIR /app
# RUN mix release 
# ENV LANG=C.UTF-8

# COPY docker-entrypoint.sh /entrypoint.sh
# RUN chmod a+x /entrypoint.sh

# # RUN adduser -home /app -u 1000 --shell /bin/sh --disabled-password  --gecos "" papercupsuser
# RUN chown -R papercupsuser:nogroup /app

# WORKDIR /app
# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["run"]


FROM elixir:1.10.4 as builder

# build step
ARG MIX_ENV=prod
ARG NODE_ENV=production
ARG APP_VER=0.0.1
ENV APP_VERSION=$APP_VER

RUN mkdir /app
WORKDIR /app

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs fswatch

# Client side
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix=assets

# fix because of https://github.com/facebook/create-react-app/issues/8413
ENV GENERATE_SOURCEMAP=false

COPY priv priv
COPY assets assets
RUN npm run build --prefix=assets

COPY mix.exs mix.lock ./
COPY config config

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

COPY lib lib
RUN mix deps.compile
RUN mix phx.digest

WORKDIR /app
RUN mix release 
FROM elixir:1.10.4 AS runner
EXPOSE 4000

ENV LANG=C.UTF-8
COPY --from=builder --chown=nobody:nogroup /app/_build/prod/rel/ /app
RUN chown -R nobody:nogroup /app

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]