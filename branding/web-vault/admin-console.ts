import { svg } from "../svg";

// PrivoHub Vault wordmark for the admin/organization console (replaces the upstream
// "vaultwarden" glyph wordmark). Identical lockup to password-manager.ts but keeps this
// file's own `admin-console-logo-clip` clip-path id so the host layout slot is unchanged.
const AdminConsoleLogo = svg`
<svg version="1.1" viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg">
<g clip-path="url(#admin-console-logo-clip)">
 <g transform="translate(14,28) scale(1.45)">
  <path d="M50 7 C50 7 74 15 83 18 C85 19 86 20 86 23 L86 49 C86 71 71 87 50 94 C29 87 14 71 14 49 L14 23 C14 20 15 19 17 18 C26 15 50 7 50 7 Z" fill="#23A06B"/>
  <circle cx="50" cy="43" r="9" fill="#fff"/>
  <path d="M45 50 L55 50 L58 67 L42 67 Z" fill="#fff"/>
 </g>
 <text x="178" y="125" textLength="600" lengthAdjust="spacingAndGlyphs" font-family="Georgia, 'Times New Roman', 'Newsreader', serif" font-size="70" font-weight="600" class="tw-fill-fg-nav">PrivoHub Vault</text>
</g>
<defs>
  <clipPath id="admin-console-logo-clip">
    <path d="M0 0h800v200H0z" class="tw-fill-fg-nav"/>
  </clipPath>
</defs>
</svg>
`;

export default AdminConsoleLogo;
