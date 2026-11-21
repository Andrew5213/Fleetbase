# Narrow Railway runtime-config fix for the pinned Fleetbase Console image.
# The upstream v0.7.63 bundle can ship with APP.disableRuntimeConfig=true, which makes
# the Console ignore fleetbase.config.json.
FROM ghcr.io/youssefsiam38/fleetbase-railway-console:1.0.1@sha256:46180b6f72eaadef2275c0c174433191bff78c4e4e4941d8c966bc1c63964c11

# The runtime entrypoint recalculates SHA-256/SHA-512 SRI after its one-token JS patch.
RUN if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache openssl; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*; \
    else \
        echo "ERROR: no supported package manager to install openssl" >&2; exit 1; \
    fi

COPY railway/console-runtime/entrypoint.sh /usr/local/bin/fleetbase-console-runtime-config-entrypoint.sh
RUN chmod +x /usr/local/bin/fleetbase-console-runtime-config-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fleetbase-console-runtime-config-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
