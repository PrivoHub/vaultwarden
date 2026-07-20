#!/usr/bin/env bash
#
# apply-branding.sh — overlay PrivoHub Vault branding onto a checked-out
# vaultwarden/vw_web_builds (Bitwarden web client) source tree, in place.
#
# Usage: apply-branding.sh <path-to-vw_web_builds-checkout>
#
# This is the SINGLE place that defines what "PrivoHub Vault" branding means at the
# web-vault source level. It is run by the `web-vault-build` stage in docker/Dockerfile.j2
# after cloning the client source and before `npm ci`/build. Everything here is source-level
# (named SVGs + plain strings) — there is NO minified-JS patching.
#
# Build guards: every upstream target is asserted to exist BEFORE we touch it, and our brand
# strings are asserted to be present AFTER. If an upstream/web-vault bump renames or moves a
# target, the relevant guard exits non-zero and fails the Docker build loudly (the brief's
# requirement) instead of silently shipping a half-branded image.

set -euo pipefail

CLIENTS="${1:?usage: apply-branding.sh <vw_web_builds checkout>}"
BRAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN="#23A06B"          # PrivoHub Vault accent (replaces Bitwarden blue #175DDC)
APP_NAME="PrivoHub Vault"

echo ">> Applying PrivoHub Vault branding to ${CLIENTS}"

die() { echo "BRANDING GUARD FAILED: $*" >&2; exit 1; }
guard_file()   { [ -f "$1" ] || die "expected file missing (upstream moved it?): $1"; }
guard_string() { grep -qF -- "$2" "$1" || die "expected string not found in $1 (upstream changed it?): $2"; }

# ---------------------------------------------------------------------------
# 1. Login / console wordmark  (inline svg`...` in TS assets, viewBox 0 0 800 200)
# ---------------------------------------------------------------------------
SVGS="${CLIENTS}/libs/assets/src/svg/svgs"
PM="${SVGS}/password-manager.ts"          # 800x200 wordmark (password manager views)
AC="${SVGS}/admin-console.ts"             # 800x200 wordmark (admin/org console)
BL="${SVGS}/bitwarden-logo.icon.ts"       # 290x60 wordmark — THE login & lock screen logo
                                          # (anon-layout.component.ts: `logo = BitwardenLogo`)
SH="${SVGS}/shield.ts"                    # 60x60 square shield icon
guard_file "$PM"; guard_string "$PM" "password-manager-logo-clip"
guard_file "$AC"; guard_string "$AC" "admin-console-logo-clip"
guard_file "$BL"; guard_string "$BL" "BitwardenLogo"; guard_string "$BL" "tw-fill-marketing-logo"
guard_file "$SH"; guard_string "$SH" "BitwardenShield"
cp -v "${BRAND_DIR}/password-manager.ts"   "$PM"
cp -v "${BRAND_DIR}/admin-console.ts"      "$AC"
cp -v "${BRAND_DIR}/bitwarden-logo.icon.ts" "$BL"
cp -v "${BRAND_DIR}/shield.ts"             "$SH"

# ---------------------------------------------------------------------------
# 2. Splash / frontend logo  (referenced by tailwind.css new-logo-themed)
# ---------------------------------------------------------------------------
IMG="${CLIENTS}/apps/web/src/images"
guard_file "${IMG}/logo.svg"; guard_file "${IMG}/logo-white.svg"
cp -v "${BRAND_DIR}/logo.svg"       "${IMG}/logo.svg"
cp -v "${BRAND_DIR}/logo-white.svg" "${IMG}/logo-white.svg"

# ---------------------------------------------------------------------------
# 3. Favicons  (rasterized from icon.svg; safari mask icon from icon-mono.svg)
# ---------------------------------------------------------------------------
ICONS="${IMG}/icons"
guard_file "${ICONS}/favicon-32x32.png"   # sanity: icon set present & in expected place
ICON="${BRAND_DIR}/icon.svg"
rsvg-convert -w 16  -h 16  "$ICON" -o "${ICONS}/favicon-16x16.png"
rsvg-convert -w 32  -h 32  "$ICON" -o "${ICONS}/favicon-32x32.png"
rsvg-convert -w 180 -h 180 "$ICON" -o "${ICONS}/apple-touch-icon.png"
rsvg-convert -w 192 -h 192 "$ICON" -o "${ICONS}/android-chrome-192x192.png"
rsvg-convert -w 512 -h 512 "$ICON" -o "${ICONS}/android-chrome-512x512.png"
rsvg-convert -w 150 -h 150 "$ICON" -o "${ICONS}/mstile-150x150.png"
cp -v "${BRAND_DIR}/icon-mono.svg" "${ICONS}/safari-pinned-tab.svg"
# Multi-resolution favicon.ico (ImageMagick 7 ships `magick`, 6 ships `convert`)
IM="$(command -v magick || command -v convert)" || die "ImageMagick (magick/convert) not found"
tmp_ico_dir="$(mktemp -d)"
for s in 16 32 48; do rsvg-convert -w "$s" -h "$s" "$ICON" -o "${tmp_ico_dir}/${s}.png"; done
"$IM" "${tmp_ico_dir}/16.png" "${tmp_ico_dir}/32.png" "${tmp_ico_dir}/48.png" "${CLIENTS}/apps/web/src/favicon.ico"
rm -rf "$tmp_ico_dir"

# ---------------------------------------------------------------------------
# 4. App name, browser-tab title, colours, alt text  (plain-string edits)
# ---------------------------------------------------------------------------
MANIFEST="${CLIENTS}/apps/web/src/manifest.json"
BROWSERCFG="${CLIENTS}/apps/web/src/browserconfig.xml"
INDEX="${CLIENTS}/apps/web/src/index.html"
ROUTER="${CLIENTS}/apps/web/src/app/core/router.service.ts"
FRONTEND="${CLIENTS}/apps/web/src/app/layouts/frontend-layout.component.html"  # frontend footer brand line
ANONFOOTER="${CLIENTS}/libs/components/src/anon-layout/anon-layout.component.html"  # LOGIN/LOCK footer brand line

guard_string "$MANIFEST"   '"name": "Vaultwarden Web"'
guard_string "$BROWSERCFG" '#175DDC'
guard_string "$INDEX"      'Vaultwarden Web'
guard_string "$INDEX"      'alt="Vaultwarden"'
guard_string "$INDEX"      '#175DDC'
# The browser-tab title default lives as a hardcoded string in the router service.
guard_string "$ROUTER"     'let title = "Vaultwarden Web";'
guard_string "$FRONTEND"   '>Vaultwarden Web<'
guard_string "$ANONFOOTER" '>Vaultwarden Web<'

sed -i "s|\"name\": \"Vaultwarden Web\"|\"name\": \"${APP_NAME}\"|"  "$MANIFEST"
sed -i "s|#175DDC|${GREEN}|g"                                        "$BROWSERCFG"
sed -i "s|>Vaultwarden Web<|>${APP_NAME}<|g"                         "$INDEX"
sed -i "s|alt=\"Vaultwarden\"|alt=\"${APP_NAME}\"|g"                 "$INDEX"
sed -i "s|#175DDC|${GREEN}|g"                                        "$INDEX"
sed -i "s|let title = \"Vaultwarden Web\";|let title = \"${APP_NAME}\";|" "$ROUTER"
# Footer brand line on the frontend/login pages. NOTE: the legal Bitwarden/Vaultwarden
# attribution disclaimer immediately below it is intentionally left intact (license/trademark
# attribution, not branding).
sed -i "s|>Vaultwarden Web<|>${APP_NAME}<|g"                         "$FRONTEND"
sed -i "s|>Vaultwarden Web<|>${APP_NAME}<|g"                         "$ANONFOOTER"

# Remaining visible logo alt-text (splash + Duo redirect connector). The `alt="Vaultwarden"` on
# index.html is handled above; these two carry the same attribute.
for alt_file in \
    "${CLIENTS}/apps/web/src/app/app.component.html" \
    "${CLIENTS}/apps/web/src/connectors/duo-redirect.html"; do
    guard_string "$alt_file" 'alt="Vaultwarden"'
    sed -i "s|alt=\"Vaultwarden\"|alt=\"${APP_NAME}\"|g" "$alt_file"
done

# ---------------------------------------------------------------------------
# 5. Post-overlay guards: confirm our brand actually landed.
# ---------------------------------------------------------------------------
guard_string "$PM"       "PrivoHub Vault"
guard_string "$BL"       "PrivoHub Vault"   # login & lock screen wordmark
guard_string "$MANIFEST" "PrivoHub Vault"
guard_string "$INDEX"    "PrivoHub Vault"
guard_string "$ROUTER"   'let title = "PrivoHub Vault";'
guard_string "$FRONTEND"   "PrivoHub Vault"
guard_string "$ANONFOOTER" "PrivoHub Vault"

echo ">> PrivoHub Vault branding applied successfully."
