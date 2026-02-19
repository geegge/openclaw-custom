# --- build gog (gogcli) ---
FROM golang:1.22-alpine AS gog-build
ARG GOGCLI_VERSION=v0.11.0

RUN apk add --no-cache git make
WORKDIR /src
RUN git clone https://github.com/steipete/gogcli.git .
RUN git checkout "${GOGCLI_VERSION}"
RUN make
# -> /src/bin/gog

# --- runtime: OpenClaw + gog in PATH ---
FROM ghcr.io/openclaw/openclaw:2026.2.12

USER root
COPY --from=gog-build /src/bin/gog /usr/local/bin/gog
RUN chmod +x /usr/local/bin/gog

USER node
