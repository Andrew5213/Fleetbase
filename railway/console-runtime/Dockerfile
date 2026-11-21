# Narrow Railway runtime-config fix for the pinned Fleetbase Console image.
# The upstream v0.7.63 bundle hardcodes APP.disableRuntimeConfig=true, so it ignores
# fleetbase.config.json even when DISABLE_RUNTIME_CONFIG=false is set in the container.
FROM ghcr.io/youssefsiam38/fleetbase-railway-console:1.0.1@sha256:46180b6f72eaadef2275c0c174433191bff78c4e4e4941d8c966bc1c63964c11

COPY railway/console-runtime/entrypoint.sh /usr/local/bin/fleetbase-console-runtime-config-entrypoint.sh
RUN chmod +x /usr/local/bin/fleetbase-console-runtime-config-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fleetbase-console-runtime-config-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
