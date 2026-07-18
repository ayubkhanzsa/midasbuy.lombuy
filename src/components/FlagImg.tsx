import { useState } from "react";
import { getFlagUrl, getCountryFlagEmoji } from "@/utils/countryFlags";
import { cn } from "@/lib/utils";

interface FlagImgProps {
  code: string;
  name?: string;
  className?: string;
}

/**
 * Renders a country flag as an SVG image (flagcdn.com) with an emoji fallback
 * for platforms/networks where the image fails to load.
 */
export const FlagImg = ({ code, name, className }: FlagImgProps) => {
  const [failed, setFailed] = useState(false);
  const cc = (code || "").toUpperCase();

  if (!cc || cc.length !== 2 || failed) {
    return (
      <span
        role="img"
        aria-label={name || cc || "flag"}
        className={cn("inline-block leading-none select-none", className)}
      >
        {getCountryFlagEmoji(cc || "UN")}
      </span>
    );
  }

  return (
    <img
      src={getFlagUrl(cc)}
      alt={name ? `${name} flag` : `${cc} flag`}
      loading="lazy"
      onError={() => setFailed(true)}
      className={cn(
        "inline-block w-5 h-[15px] object-cover rounded-[2px] align-middle shadow-sm",
        className
      )}
    />
  );
};

export default FlagImg;
