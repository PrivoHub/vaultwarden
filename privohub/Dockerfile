# PrivoHub Vault: thin rebrand of upstream Vaultwarden.
#
# Upstream ships its logo as image files the login-page CSS references
# (images/logo.svg + logo-white.svg) and a set of favicons; we overlay our own.
# We ship NO custom web-vault CSS theme; Vaultwarden keeps its stock colors; this
# image only swaps the baked-in assets that CSS cannot reach (logo files, favicons,
# manifest/browserconfig text).
#
# Build (from the repository root):
#   docker build --platform linux/amd64 -t vaultwarden-privohub:1.37.4 privohub/
# VW_VERSION picks the official image to rebrand; keep it equal to the upstream
# release this branch is based on.

ARG VW_VERSION=1.37.4

# ── Stage 1: rasterize favicons + rebrand text assets ──────────────────────────
FROM vaultwarden/server:${VW_VERSION} AS upstream

FROM alpine:3.20 AS assets
RUN apk add --no-cache rsvg-convert imagemagick perl
WORKDIR /a
COPY assets/ ./src/

# PNG favicons from the square shield icon, plus a multi-resolution favicon.ico
# and raster fallbacks for the wordmark lockups.
RUN set -eux; \
    for s in 16 32 48 150 180 192 512; do \
      rsvg-convert -w "$s" -h "$s" src/icon.svg -o "icon-$s.png"; \
    done; \
    convert icon-16.png icon-32.png icon-48.png favicon.ico; \
    rsvg-convert -w 400 src/logo.svg       -o "logo-dark@2x.png"; \
    rsvg-convert -w 400 src/logo-white.svg -o "logo-white@2x.png"

# Rebrand the text assets (PWA name, tile/mask colours, alt text) off the upstream
# copies, so the final stage needs no tooling.
COPY --from=upstream /web-vault/manifest.json /web-vault/browserconfig.xml /web-vault/index.html ./txt/
RUN set -eux; \
    sed -i 's/"Vaultwarden Web"/"PrivoHub Vault"/' txt/manifest.json; \
    sed -i 's/#175DDC/#23A06B/g' txt/browserconfig.xml txt/index.html; \
    sed -i 's/alt="Vaultwarden"/alt="PrivoHub Vault"/g' txt/index.html

# The web-vault renders its wordmark from inline SVGs baked into the JS chunks (the
# index.html <img> is only the pre-boot splash). The chunks are content-hash-named
# with no SRI, so editing them is safe. Two wordmarks, each swapped by viewBox so the
# layout slot is unchanged:
#   * viewBox "0 0 800 200": the password-manager wordmark (login page in a lazy
#     top-level chunk + the dashboard in `app/main.*.js`). The lazy chunk's NUMBER
#     changes between web-vault releases (155 in 2026.4.1, 848 in 2026.7.0), so it is
#     found by content, never by name.
#   * viewBox "0 0 290 60":  the anon-layout BitwardenLogo (LOGIN + LOCK/UNLOCK
#     screens) in `app/main.*.js`.
#   * viewBox "0 0 60 60":   the BitwardenShield square icon (compact/collapsed nav
#     logo) in `app/main.*.js`.
# All three live in `app/main.*.js`; missing that file's patch is what left the unlock
# screen + dashboard on the stock Vaultwarden logo. Guards assert each splice landed
# (our wordmarks carry textLength=222/600 which upstream's do not, and no upstream
# `<title>Vaultwarden</title>` may survive).
COPY --from=upstream /web-vault/ ./wv/
RUN set -eu; mkdir -p out/app; \
    login=$(grep -lF 'viewBox="0 0 800 200"' wv/*.js || true); \
    [ -n "$login" ] || { echo "no top-level chunk holds the 800x200 wordmark"; exit 1; }; \
    for f in $login; do \
      perl -0777 -i -pe 'BEGIN{open my $f,"<","/a/src/login-logo.svg" or die; local $/; $r=<$f>; chomp $r;} s{<svg[^>]*viewBox="0 0 800 200".*?</svg>}{$r}sg' "$f"; \
      grep -q "PrivoHub Vault" "$f"; cp "$f" out/; \
    done   # fail the build if the splice didn't match

RUN set -eu; m=$(ls wv/app/main.*.js); \
    perl -0777 -i -pe 'BEGIN{open my $f,"<","/a/src/login-lock-logo.svg" or die; local $/; $r=<$f>; chomp $r;} s{<svg[^>]*viewBox="0 0 290 60".*?</svg>}{$r}sg' $m; \
    perl -0777 -i -pe 'BEGIN{open my $f,"<","/a/src/login-logo.svg" or die; local $/; $r=<$f>; chomp $r;} s{<svg[^>]*viewBox="0 0 800 200".*?</svg>}{$r}sg' $m; \
    perl -0777 -i -pe 'BEGIN{open my $f,"<","/a/src/login-shield.svg" or die; local $/; $r=<$f>; chomp $r;} s{<svg[^>]*viewBox="0 0 60 60".*?</svg>}{$r}sg' $m; \
    grep -q 'textLength="222"' $m; \
    grep -q 'textLength="600"' $m; \
    ! grep -q '<title>Vaultwarden</title>' $m; \
    cp $m out/app/   # fail if any splice missed

# ── Stage 2: thin overlay on the official image ────────────────────────────────
FROM vaultwarden/server:${VW_VERSION}

# Login-page wordmark (SVG referenced by the web-vault CSS) + raster fallbacks.
COPY assets/logo.svg assets/logo-white.svg /web-vault/images/
COPY --from=assets /a/logo-dark@2x.png /a/logo-white@2x.png /web-vault/images/

# Square icon (SVG) + monochrome Safari pinned-tab silhouette.
COPY assets/icon.svg      /web-vault/images/icon-white.svg
COPY assets/icon-mono.svg /web-vault/images/safari-pinned-tab.svg
COPY assets/icon-mono.svg /web-vault/images/icons/safari-pinned-tab.svg

# Favicons: top level + both image directories the web-vault references.
COPY --from=assets /a/favicon.ico /web-vault/favicon.ico
COPY --from=assets /a/icon-16.png  /web-vault/images/favicon-16x16.png
COPY --from=assets /a/icon-32.png  /web-vault/images/favicon-32x32.png
COPY --from=assets /a/icon-180.png /web-vault/images/apple-touch-icon.png
COPY --from=assets /a/icon-192.png /web-vault/images/android-chrome-192x192.png
COPY --from=assets /a/icon-512.png /web-vault/images/android-chrome-512x512.png
COPY --from=assets /a/icon-150.png /web-vault/images/mstile-150x150.png
COPY --from=assets /a/icon-32.png  /web-vault/images/icon-white.png
COPY --from=assets /a/icon-32.png  /web-vault/images/icon-dark.png
COPY --from=assets /a/icon-16.png  /web-vault/images/icons/favicon-16x16.png
COPY --from=assets /a/icon-32.png  /web-vault/images/icons/favicon-32x32.png
COPY --from=assets /a/icon-180.png /web-vault/images/icons/apple-touch-icon.png
COPY --from=assets /a/icon-192.png /web-vault/images/icons/android-chrome-192x192.png
COPY --from=assets /a/icon-512.png /web-vault/images/icons/android-chrome-512x512.png
COPY --from=assets /a/icon-150.png /web-vault/images/icons/mstile-150x150.png

# Rebranded text assets.
COPY --from=assets /a/txt/manifest.json    /web-vault/manifest.json
COPY --from=assets /a/txt/browserconfig.xml /web-vault/browserconfig.xml
COPY --from=assets /a/txt/index.html       /web-vault/index.html

# Patched JS chunks (wordmarks → PrivoHub Vault), same hashed filenames:
#   <lazy chunk>.js → login-page wordmark (800×200), found by content
#   app/main.*.js   → dashboard wordmark (800×200) + lock/unlock (290×60) + shield (60×60)
COPY --from=assets /a/out/ /web-vault/
