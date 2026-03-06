# --- build gog (gogcli) ---
FROM golang:1.25-alpine AS gog-build

ARG GOGCLI_VERSION=v0.11.0

RUN apk add --no-cache git make bash

WORKDIR /src
RUN git clone https://github.com/steipete/gogcli.git .
RUN git checkout "${GOGCLI_VERSION}"
RUN make  # -> /src/bin/gog

# --- runtime: OpenClaw + gog + CalDAV tooling ---
FROM ghcr.io/openclaw/openclaw:2026.2.12

USER root

# Install CalDAV tooling needed by the caldav-calendar skill:
# - vdirsyncer (CalDAV sync)
# - khal (calendar tooling)
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       vdirsyncer \
       khal \
       ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Add gog to PATH
COPY --from=gog-build /src/bin/gog /usr/local/bin/gog
RUN chmod +x /usr/local/bin/gog

# Bundle the caldav-calendar skill (from this repo)
WORKDIR /app
COPY --chown=node:node skills/caldav-calendar /app/skills/caldav-calendar

USER node
