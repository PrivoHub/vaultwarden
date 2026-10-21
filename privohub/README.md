# PrivoHub Vault branding overlay

PrivoHub Vault is Vaultwarden, unmodified on the server side. The only change is
branding: this directory builds a thin image on top of the official
`vaultwarden/server` release that swaps the logos, favicons and app name in the
bundled web-vault, so the web UI reads "PrivoHub Vault".

- `Dockerfile`: starts from `vaultwarden/server:${VW_VERSION}`, rasterizes the
  favicons, rebrands `manifest.json`, `browserconfig.xml` and `index.html`, and
  replaces the inline SVG wordmarks in the web-vault's JavaScript (matched by
  `viewBox`, so the layout is unchanged). Every replacement is checked during the
  build, so a web-vault release that moves them fails the build instead of
  shipping a half-branded UI.
- `assets/`: the logos and icons.

Build from the repository root:

    docker build --platform linux/amd64 -t vaultwarden-privohub:1.37.4 privohub/

The rest of this repository is upstream Vaultwarden at the tag this branch is
based on (`1.37.4`).
