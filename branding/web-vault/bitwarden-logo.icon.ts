import { svg } from "../svg";

// PrivoHub Vault wordmark for the anon-layout (the LOGIN and LOCK screens render this via
// libs/components/src/anon-layout/anon-layout.component.ts -> `protected logo = BitwardenLogo`).
// Replaces the upstream "vaultwarden" glyph wordmark. Keeps the named export `BitwardenLogo`,
// the 0 0 290 60 viewBox, and the `tw-fill-marketing-logo` class on the text so it stays legible
// on the themed anon-layout surface. The shield is fixed PrivoHub-Vault green; `textLength`
// guarantees the wordmark can never overflow the slot regardless of the fallback serif.
export const BitwardenLogo = svg`
<svg version="1.1" viewBox="0 0 290 60" xmlns="http://www.w3.org/2000/svg">
  <title>PrivoHub Vault</title>
  <g transform="translate(4,6) scale(0.48)">
    <path d="M50 7 C50 7 74 15 83 18 C85 19 86 20 86 23 L86 49 C86 71 71 87 50 94 C29 87 14 71 14 49 L14 23 C14 20 15 19 17 18 C26 15 50 7 50 7 Z" fill="#23A06B"/>
    <circle cx="50" cy="43" r="9" fill="#fff"/>
    <path d="M45 50 L55 50 L58 67 L42 67 Z" fill="#fff"/>
  </g>
  <text x="58" y="40" textLength="222" lengthAdjust="spacingAndGlyphs" font-family="Georgia, 'Times New Roman', 'Newsreader', serif" font-size="27" font-weight="600" class="tw-fill-marketing-logo">PrivoHub Vault</text>
</svg>
`;
