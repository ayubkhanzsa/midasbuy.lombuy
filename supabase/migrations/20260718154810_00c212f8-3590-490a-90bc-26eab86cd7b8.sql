
-- Backfill missing profiles from auth.users
INSERT INTO public.profiles (user_id, email, full_name, avatar_url, provider, email_verified)
SELECT u.id, u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', u.raw_user_meta_data->>'user_name'),
  u.raw_user_meta_data->>'avatar_url',
  COALESCE(u.raw_app_meta_data->>'provider', 'email'),
  u.email_confirmed_at IS NOT NULL
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE p.user_id IS NULL;

-- Fill missing emails on existing profiles from auth.users
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.user_id = u.id AND (p.email IS NULL OR p.email = '');

-- Ensure profile always exists when an order is inserted
CREATE OR REPLACE FUNCTION public.ensure_profile_for_order()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE u_email TEXT; u_meta jsonb; u_app jsonb; u_confirmed timestamptz;
BEGIN
  IF NEW.user_id IS NULL THEN RETURN NEW; END IF;
  SELECT email, raw_user_meta_data, raw_app_meta_data, email_confirmed_at
    INTO u_email, u_meta, u_app, u_confirmed
    FROM auth.users WHERE id = NEW.user_id;
  IF u_email IS NULL THEN RETURN NEW; END IF;
  INSERT INTO public.profiles (user_id, email, full_name, avatar_url, provider, email_verified)
  VALUES (
    NEW.user_id, u_email,
    COALESCE(u_meta->>'full_name', u_meta->>'name', u_meta->>'user_name'),
    u_meta->>'avatar_url',
    COALESCE(u_app->>'provider', 'email'),
    u_confirmed IS NOT NULL
  )
  ON CONFLICT (user_id) DO UPDATE
    SET email = COALESCE(NULLIF(public.profiles.email, ''), EXCLUDED.email);
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS trg_ensure_profile_for_order ON public.orders;
CREATE TRIGGER trg_ensure_profile_for_order
BEFORE INSERT ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.ensure_profile_for_order();
