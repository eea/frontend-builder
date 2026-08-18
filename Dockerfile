# syntax=docker/dockerfile:1
# EEA frontend builder = Plone frontend-builder (Volto project + pnpm + core)
# + Chromium, so add-on Dockerfiles only need to overlay the add-on.
FROM plone/frontend-builder:18

ARG CHROMIUM_VERSION=149.0.7827.196-1~deb12u1

ENV HOST="0.0.0.0"
ENV CHROME_BIN="/usr/bin/chromium"
ENV CHROMIUM_BIN="/usr/bin/chromium"
ENV CYPRESS_BROWSER_PATH="/usr/bin/chromium"

LABEL maintainer="European Environment Agency <eea-edw-a-team-alerts@googlegroups.com>" \
      org.label-schema.name="eea-frontend-builder" \
      org.label-schema.description="EEA Plone Volto 18 frontend builder (Volto project + Chromium for Cypress)" \
      org.label-schema.vendor="European Environment Agency"

# Cypress dependencies + Chromium (pinned via a Debian snapshot for reproducibility)
USER root
RUN apt-get update -q \
    && apt-get install -qy --no-install-recommends \
        libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 \
        libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /etc/apt/sources.list.d /etc/apt/preferences.d /etc/apt/apt.conf.d; \
    printf '%s\n' 'Acquire::Check-Valid-Until "false";' \
      > /etc/apt/apt.conf.d/99snapshot-no-check-valid-until; \
    printf '%s\n' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20260630T000000Z bookworm-security main' \
      'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20260630T000000Z bookworm main' \
      > /etc/apt/sources.list.d/bookworm-chromium149-snapshot.list; \
    apt-get update -q; \
    apt-get install -qy --no-install-recommends \
      "chromium=${CHROMIUM_VERSION}" "chromium-common=${CHROMIUM_VERSION}"; \
    apt-mark hold chromium chromium-common; \
    rm -rf /var/lib/apt/lists/*

USER node
WORKDIR /app