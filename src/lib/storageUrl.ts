import { supabase } from "@/integrations/supabase/client";

// Cache resolved signed URLs so we don't re-sign the same object repeatedly
const signedCache = new Map<string, string>();

/**
 * If the given URL is a "public" storage URL for the private `site-assets` bucket
 * (which returns 400 because the bucket cannot be made public in this workspace),
 * transform it into a long-lived signed URL. Any other URL is returned unchanged.
 */
export async function resolveStorageUrl(url: string | null | undefined): Promise<string | null> {
  if (!url) return null;
  const marker = "/storage/v1/object/public/site-assets/";
  const idx = url.indexOf(marker);
  if (idx === -1) return url; // already a signed / external / asset URL

  if (signedCache.has(url)) return signedCache.get(url)!;

  const path = url.substring(idx + marker.length);
  try {
    // 10 years
    const { data, error } = await supabase.storage
      .from("site-assets")
      .createSignedUrl(path, 60 * 60 * 24 * 365 * 10);
    if (error || !data?.signedUrl) return url;
    signedCache.set(url, data.signedUrl);
    return data.signedUrl;
  } catch {
    return url;
  }
}

/** Resolve an array of URLs in parallel, preserving order & nulls. */
export async function resolveStorageUrls(urls: (string | null | undefined)[]): Promise<(string | null)[]> {
  return Promise.all(urls.map(resolveStorageUrl));
}
