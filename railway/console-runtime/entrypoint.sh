#!/bin/sh
set -eu

ASSET_DIR=/usr/share/nginx/html/assets
patched=0

# In this pinned production bundle, !0 is minified JavaScript for true and !1 is false.
# Fail closed if the upstream bundle changes so we never serve a console that silently
# ignores its API host configuration.
for asset in "$ASSET_DIR"/@fleetbase/console-*.js; do
    [ -f "$asset" ] || continue
    if grep -q 'disableRuntimeConfig:!0' "$asset"; then
        sed -i 's/disableRuntimeConfig:!0/disableRuntimeConfig:!1/g' "$asset"
        patched=1
    fi
done

if [ "$patched" -ne 1 ]; then
    printf '%s\n' "ERROR: expected Fleetbase console runtime-config flag was not found" >&2
    exit 1
fi

exec /usr/local/bin/fleetbase-console-entrypoint.sh "$@"
