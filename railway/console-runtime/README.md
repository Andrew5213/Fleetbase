# Railway Console runtime-config compatibility

This small image layer works around the pinned Fleetbase Console v0.7.63 bundle setting
`APP.disableRuntimeConfig` to `true` unconditionally. That causes the Console to ignore
`/fleetbase.config.json` and call API routes against the Console's own static web server.

The entrypoint flips only that bundled flag, fails safely if the bundle no longer matches,
then calls the base image entrypoint. The base image continues to generate the runtime config
from Railway variables such as `API_HOST`, `API_NAMESPACE`, and SocketCluster settings.

The base wrapper image is pinned by digest. Update the digest and re-check the flag before
upgrading the console.
