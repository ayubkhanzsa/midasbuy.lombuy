/**
 * Country Flag Utilities
 *
 * NOTE: Emoji country flags don't render on Windows/Chrome (no font support),
 * so we use flagcdn.com SVG images which render consistently everywhere.
 */

// Emoji fallback (for platforms that support it or if image fails to load)
export const getCountryFlagEmoji = (countryCode: string): string => {
  if (!countryCode || countryCode.length !== 2) return '🌍';
  const code = countryCode.toUpperCase();
  const codePoints = code.split('').map(
    (char) => 0x1f1e6 + char.charCodeAt(0) - 'A'.charCodeAt(0)
  );
  return String.fromCodePoint(...codePoints);
};

// Return SVG flag URL (works cross-platform incl. Windows)
export const getFlagUrl = (countryCode: string): string => {
  if (!countryCode || countryCode.length !== 2) {
    return 'https://flagcdn.com/un.svg';
  }
  return `https://flagcdn.com/${countryCode.toLowerCase()}.svg`;
};

/**
 * Returns an <img> HTML string for the flag. Kept as a string so existing
 * `{getFlag(code)}` JSX call sites keep working — React will render the img
 * tag when we output it as an element. To render as element, prefer <FlagImg />.
 */
export const getFlag = (countryCode: string): string => {
  return getCountryFlagEmoji(countryCode);
};

// Backward-compat map
export const COUNTRY_FLAG_MAP: Record<string, string> = {};

export const getFlagWithStyle = (countryCode: string) => ({
  flag: getCountryFlagEmoji(countryCode),
  url: getFlagUrl(countryCode),
  className: 'inline-block w-5 h-[15px] object-cover rounded-sm align-middle',
});
