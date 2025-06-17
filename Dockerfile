# syntax=docker/dockerfile:1
FROM plone/frontend-builder:16.19.0

USER root

ENV HOST="0.0.0.0"

RUN runDeps="ca-certificates git chromium libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb wget procps jq" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $runDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER node
