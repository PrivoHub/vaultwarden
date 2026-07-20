# PrivoHub Vault — web-vault branding assets

These files define the **PrivoHub Vault** branding that is baked into the web-vault at build
time by the `web-vault-build` stage in `docker/Dockerfile.j2`. They are overlaid onto a
checked-out `vaultwarden/vw_web_builds` (Bitwarden web client) source tree by
[`apply-branding.sh`](./apply-branding.sh) **before** the Angular build runs — so branding is
correct at the source level, with no minified-JS patching.

See the repo-root [`CLAUDE.md`](../../CLAUDE.md) for the full flow, version pinning, and the
release/tagging convention.

## Brand
- Accent (Vault green): `#23A06B` (replaces upstream Bitwarden blue `#175DDC`)
- Ink (text on light): `#211E35`
- Motif: the PrivoHub "Aegis" shield + white keyhole (the Vault product mark)
- Wordmark: "PrivoHub Vault", serif (Georgia / Newsreader-like), weight 600

## Files
| File | Purpose | Overlaid onto (in the client tree) |
|---|---|---|
| `bitwarden-logo.icon.ts` | **Login + lock screen wordmark** (`BitwardenLogo`, `viewBox 0 0 290 60`, used by `anon-layout.component.ts`) | `libs/assets/src/svg/svgs/bitwarden-logo.icon.ts` |
| `password-manager.ts` | Password-manager-view wordmark (`viewBox 0 0 800 200`) | `libs/assets/src/svg/svgs/password-manager.ts` |
| `admin-console.ts` | Admin/org console wordmark | `libs/assets/src/svg/svgs/admin-console.ts` |
| `shield.ts` | Square shield icon (`BitwardenShield`, `viewBox 0 0 60 60`) | `libs/assets/src/svg/svgs/shield.ts` |
| `logo.svg` | Horizontal lockup, light theme (splash/frontend) | `apps/web/src/images/logo.svg` |
| `logo-white.svg` | Horizontal lockup, dark theme | `apps/web/src/images/logo-white.svg` |
| `icon.svg` | Square colour app icon — **source for all favicons** | rasterized → `apps/web/src/favicon.ico` + `images/icons/*` |
| `icon-mono.svg` | Single-colour silhouette (keyhole punched via evenodd) | `apps/web/src/images/icons/safari-pinned-tab.svg` |
| `apply-branding.sh` | Applies all of the above + string/colour edits + build guards | — |

The login/console wordmarks keep upstream's `viewBox="0 0 800 200"`, their `*-logo-clip`
clip-paths, and the `tw-fill-fg-nav` class on the text (so it stays legible on light **and**
dark login themes). The text uses `textLength` so it can never overflow the slot regardless of
which serif font the browser falls back to.

## Editing / previewing
Edit the SVGs here, then preview without a full build:
```bash
# from this directory
sed 's/class="tw-fill-fg-nav"/fill="#211E35"/' password-manager.ts | sed -n '/<svg/,/<\/svg>/p' > /tmp/login.svg
docker run --rm -v /tmp:/t -w /t debian:trixie-slim \
  bash -c "apt-get update -qq && apt-get install -y -qq --no-install-recommends librsvg2-bin fonts-dejavu-core >/dev/null && rsvg-convert -b white login.svg -o login.png"
```
Then a `docker build` of the repo re-applies them and the guards in `apply-branding.sh` will
fail loudly if any upstream target moved.
