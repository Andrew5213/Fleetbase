#!/bin/sh
set -eu

ASSET_DIR=/usr/share/nginx/html/assets
INDEX_FILE=/usr/share/nginx/html/index.html
patched=0

# In this pinned production bundle, !0 is minified JavaScript for true and !1 is false.
# Fail closed if the upstream bundle changes so we never serve a console that silently
# ignores its API host configuration.
for asset in "$ASSET_DIR"/@fleetbase/console-*.js; do
    [ -f "$asset" ] || continue
    if grep -q 'disableRuntimeConfig:!0' "$asset"; then
        sed -i 's/disableRuntimeConfig:!0/disableRuntimeConfig:!1/g' "$asset"

        # The HTML uses Subresource Integrity (SRI) for this bundle. Recalculate both hashes
        # after the narrow patch so browsers accept the modified asset and still verify it.
        hash256="$(openssl dgst -sha256 -binary "$asset" | openssl base64 -A)"
        hash512="$(openssl dgst -sha512 -binary "$asset" | openssl base64 -A)"
        asset_name="${asset##*/}"
        sed -i "/$asset_name/s|integrity=\"[^\"]*\"|integrity=\"sha256-$hash256 sha512-$hash512\"|" "$INDEX_FILE"
        if ! grep -Fq "integrity=\"sha256-$hash256 sha512-$hash512\"" "$INDEX_FILE"; then
            printf '%s\n' "ERROR: failed to refresh console bundle SRI hashes" >&2
            exit 1
        fi
        patched=1
    fi
done

if [ "$patched" -ne 1 ]; then
    printf '%s\n' "ERROR: expected Fleetbase console runtime-config flag was not found" >&2
    exit 1
fi

exec /usr/local/bin/fleetbase-console-entrypoint.sh "$@"
