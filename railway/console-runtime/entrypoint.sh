#!/bin/sh
set -eu

ASSET_DIR=/usr/share/nginx/html/assets
INDEX_FILE=/usr/share/nginx/html/index.html
bundle_ready=0

# The pinned console may ship with either value. Ensure runtime config is enabled,
# then recalculate SRI so browsers continue verifying the modified bundle.
for asset in "$ASSET_DIR"/@fleetbase/console-*.js; do
    [ -f "$asset" ] || continue

    if grep -q 'disableRuntimeConfig:!0' "$asset"; then
        sed -i 's/disableRuntimeConfig:!0/disableRuntimeConfig:!1/g' "$asset"
    fi

    if grep -q 'disableRuntimeConfig:!1' "$asset"; then
        hash256="$(openssl dgst -sha256 -binary "$asset" | openssl base64 -A)"
        hash512="$(openssl dgst -sha512 -binary "$asset" | openssl base64 -A)"
        asset_name="${asset##*/}"
        sed -i "/$asset_name/s|integrity=\"[^\"]*\"|integrity=\"sha256-$hash256 sha512-$hash512\"|" "$INDEX_FILE"
        if ! grep -Fq "integrity=\"sha256-$hash256 sha512-$hash512\"" "$INDEX_FILE"; then
            printf '%s\n' "ERROR: failed to refresh console bundle SRI hashes" >&2
            exit 1
        fi
        bundle_ready=1
    fi
done

if [ "$bundle_ready" -ne 1 ]; then
    printf '%s\n' "ERROR: could not enable runtime config in the Fleetbase console bundle" >&2
    exit 1
fi

exec /usr/local/bin/fleetbase-console-entrypoint.sh "$@"
