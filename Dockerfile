# syntax=docker/dockerfile:1
FROM plone/frontend-builder:17 as SOURCE

FROM node:18-bullseye-slim
ENV VOLTO_VERSION=17

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="frontend-base" \
      org.label-schema.description="Plone frontend builder image" \
      org.label-schema.vendor="Plone Foundation"

RUN <<EOT
    set -e
    apt update
    apt install -y --no-install-recommends python3 build-essential git ca-certificates
    npm install --no-audit --no-fund -g yo @plone/generator-volto@8
    mkdir /app
    chown -R node:node /app
    rm -rf /var/lib/apt/lists/*
EOT

WORKDIR /app
RUN corepack enable

USER node
RUN <<EOT
    set -e
    yo @plone/volto \
        app \
        --description "Plone frontend using Volto" \
        --skip-addons \
        --skip-install \
        --skip-workspaces \
        --volto=${VOLTO_VERSION} \
        --no-interactive
    yarn install --network-timeout 1000000
EOT

COPY --from=SOURCE --chown=node:node /setupAddon  /setupAddon

USER root

RUN runDeps="ca-certificates git chromium libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb wget procps jq" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $runDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER node
