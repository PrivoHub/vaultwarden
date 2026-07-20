import { svg } from "../svg";

// PrivoHub Vault login wordmark (replaces the upstream "vaultwarden" glyph wordmark).
// Rendered on the auth/login screen. viewBox 0 0 800 200 and the
// `password-manager-logo-clip` clip-path are preserved so the host layout slot is unchanged.
// The shield is fixed PrivoHub-Vault green (#23A06B, legible on light & dark); the wordmark
// text uses `tw-fill-fg-nav` so it inherits the theme foreground colour.
const PasswordManagerLogo = svg`
<svg version="1.1" viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg">
<g clip-path="url(#password-manager-logo-clip)">
 <g transform="translate(14,28) scale(1.45)">
  <path d="M50 7 C50 7 74 15 83 18 C85 19 86 20 86 23 L86 49 C86 71 71 87 50 94 C29 87 14 71 14 49 L14 23 C14 20 15 19 17 18 C26 15 50 7 50 7 Z" fill="#23A06B"/>
  <circle cx="50" cy="43" r="9" fill="#fff"/>
  <path d="M45 50 L55 50 L58 67 L42 67 Z" fill="#fff"/>
 </g>
 <text x="178" y="125" textLength="600" lengthAdjust="spacingAndGlyphs" font-family="Georgia, 'Times New Roman', 'Newsreader', serif" font-size="70" font-weight="600" class="tw-fill-fg-nav">PrivoHub Vault</text>
</g>
<defs>
  <clipPath id="password-manager-logo-clip">
    <path class="tw-fill-fg-nav" d="M0 0h800v200H0z"/>
  </clipPath>
</defs>
</svg>
`;

export default PasswordManagerLogo;
