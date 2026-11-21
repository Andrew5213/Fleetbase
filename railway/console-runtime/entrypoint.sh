#!/bin/sh
set -eu

ASSET_DIR=/usr/share/nginx/html/assets
INDEX_FILE=/usr/share/nginx/html/index.html
bundle_ready=0

# Enable runtime config in the pinned bundle. Because the bytes change at startup,
# publish them under a new URL so browsers cannot reuse a cached pre-patch bundle.
for asset in "$ASSET_DIR"/@fleetbase/console-*.js; do
    [ -f "$asset" ] || continue

    if grep -q 'disableRuntimeConfig:!0' "$asset"; then
        sed -i 's/disableRuntimeConfig:!0/disableRuntimeConfig:!1/g' "$asset"
    fi

    if grep -q 'disableRuntimeConfig:!1' "$asset"; then
        asset_name="${asset##*/}"
        case "$asset_name" in
            *-runtime-config.js)
                ;;
            *)
                versioned_name="${asset_name%.js}-runtime-config.js"
                mv "$asset" "$ASSET_DIR/@fleetbase/$versioned_name"
                sed -i "s|$asset_name|$versioned_name|g" "$INDEX_FILE"
                asset="$ASSET_DIR/@fleetbase/$versioned_name"
                asset_name="$versioned_name"
                ;;
        esac

        if ! grep -Fq "src=\"/assets/@fleetbase/$asset_name\"" "$INDEX_FILE"; then
            printf '%s\n' "ERROR: failed to version the console bundle URL" >&2
            exit 1
        fi

        hash256="$(openssl dgst -sha256 -binary "$asset" | openssl base64 -A)"
        hash512="$(openssl dgst -sha512 -binary "$asset" | openssl base64 -A)"
        sed -i "/$asset_name/s|integrity=\\"[^\\"]*\\"|integrity=\\"sha256-$hash256 sha512-$hash512\\"|" "$INDEX_FILE"
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
