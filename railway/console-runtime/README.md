# Railway Console runtime-config compatibility

This small image layer ensures the pinned Fleetbase Console bundle enables runtime configuration.
Depending on the base image build, the minified `APP.disableRuntimeConfig` flag may arrive as
either true or false; the entrypoint enables it when needed and verifies it is enabled.

Afterward, it recalculates the bundle's SHA-256 and SHA-512 Subresource Integrity (SRI) hashes
in `index.html`, so browsers continue to verify the modified JavaScript. It then calls the base
image entrypoint, which writes `/fleetbase.config.json` from Railway variables such as
`API_HOST`, `API_NAMESPACE`, and SocketCluster settings.

The base wrapper image is pinned by digest. Update the digest and re-check the flag before
upgrading the console.
