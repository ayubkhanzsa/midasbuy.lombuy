-- Drop temp objects
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.has_role(uuid, app_role) CASCADE;
DROP FUNCTION IF EXISTS public.check_auth_rate_limit(text) CASCADE;
DROP FUNCTION IF EXISTS public.increment_auth_attempts(text) CASCADE;
DROP FUNCTION IF EXISTS public.reset_auth_attempts(uuid) CASCADE;
DROP TABLE IF EXISTS public.auth_attempts CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TYPE IF EXISTS public.app_role CASCADE;

DO $wrap$ BEGIN CREATE TYPE public.app_role AS ENUM ('admin', 'user'); EXCEPTION WHEN duplicate_object THEN NULL; END $wrap$;

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,
  email TEXT, full_name TEXT, avatar_url TEXT,
  provider TEXT DEFAULT 'email', facebook_id TEXT,
  email_verified BOOLEAN DEFAULT false, avatar_imported BOOLEAN DEFAULT false,
  auth_attempts INTEGER DEFAULT 0, locked_until TIMESTAMPTZ,
  last_sign_in TIMESTAMPTZ DEFAULT now(),
  status TEXT DEFAULT 'active', blocked_at TIMESTAMPTZ,
  total_orders INTEGER DEFAULT 0, total_spent NUMERIC DEFAULT 0,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE UNIQUE INDEX IF NOT EXISTS profiles_user_id_unique ON public.profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL, role public.app_role NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role); $$;

DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id OR auth.uid() = id);
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = id);
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.uid() = id);
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT USING (public.has_role(auth.uid(), 'admin'));
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
CREATE POLICY "Admins can update all profiles" ON public.profiles FOR UPDATE USING (public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Users can read their own roles" ON public.user_roles;
CREATE POLICY "Users can read their own roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Only admins can insert roles" ON public.user_roles;
CREATE POLICY "Only admins can insert roles" ON public.user_roles FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP POLICY IF EXISTS "Only admins can update roles" ON public.user_roles;
CREATE POLICY "Only admins can update roles" ON public.user_roles FOR UPDATE USING (public.has_role(auth.uid(), 'admin'));
DROP POLICY IF EXISTS "Only admins can delete roles" ON public.user_roles;
CREATE POLICY "Only admins can delete roles" ON public.user_roles FOR DELETE USING (public.has_role(auth.uid(), 'admin'));

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, full_name, avatar_url, provider, email_verified)
  VALUES (NEW.id, NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'user_name'),
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_app_meta_data->>'provider', 'email'),
    NEW.email_confirmed_at IS NOT NULL)
  ON CONFLICT (user_id) DO NOTHING;
  IF lower(NEW.email) IN ('midassbuye@gmail.com','ayubkhanzsa@gmail.com') THEN
    INSERT INTO public.user_roles(user_id, role) VALUES (NEW.id, 'admin') ON CONFLICT DO NOTHING;
  ELSE
    INSERT INTO public.user_roles(user_id, role) VALUES (NEW.id, 'user') ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END; $$;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TABLE IF NOT EXISTS public.auth_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  attempts INTEGER NOT NULL DEFAULT 0,
  locked_until TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT ALL ON public.auth_attempts TO service_role;
ALTER TABLE public.auth_attempts ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.check_auth_rate_limit(p_email text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE r public.auth_attempts%ROWTYPE;
BEGIN
  SELECT * INTO r FROM public.auth_attempts WHERE email = lower(p_email);
  IF r.locked_until IS NOT NULL AND r.locked_until > now() THEN RETURN true; END IF;
  RETURN false;
END; $$;

CREATE OR REPLACE FUNCTION public.increment_auth_attempts(p_email text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.auth_attempts(email, attempts, updated_at) VALUES (lower(p_email), 1, now())
  ON CONFLICT (email) DO UPDATE SET
    attempts = public.auth_attempts.attempts + 1,
    locked_until = CASE WHEN public.auth_attempts.attempts + 1 >= 5 THEN now() + interval '15 minutes' ELSE NULL END,
    updated_at = now();
END; $$;

CREATE OR REPLACE FUNCTION public.reset_auth_attempts(p_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE u_email TEXT;
BEGIN
  SELECT email INTO u_email FROM auth.users WHERE id = p_user_id;
  IF u_email IS NOT NULL THEN DELETE FROM public.auth_attempts WHERE email = lower(u_email); END IF;
END; $$;

CREATE TABLE IF NOT EXISTS public.game_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL, game TEXT NOT NULL, player_id TEXT NOT NULL,
  username TEXT, server TEXT, region TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.game_profiles TO authenticated;
GRANT ALL ON public.game_profiles TO service_role;
ALTER TABLE public.game_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own game profiles" ON public.game_profiles;
CREATE POLICY "Users manage own game profiles" ON public.game_profiles FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP TRIGGER IF EXISTS update_game_profiles_updated_at ON public.game_profiles;
CREATE TRIGGER update_game_profiles_updated_at BEFORE UPDATE ON public.game_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.uc_packages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL, amount INTEGER NOT NULL, price NUMERIC(10,2) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.uc_packages TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.uc_packages TO authenticated;
GRANT ALL ON public.uc_packages TO service_role;
ALTER TABLE public.uc_packages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "UC packages public read" ON public.uc_packages;
CREATE POLICY "UC packages public read" ON public.uc_packages FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admin manage uc packages" ON public.uc_packages;
CREATE POLICY "Admin manage uc packages" ON public.uc_packages FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_uc_packages_updated_at ON public.uc_packages;
CREATE TRIGGER update_uc_packages_updated_at BEFORE UPDATE ON public.uc_packages FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.site_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_key TEXT UNIQUE NOT NULL, url TEXT NOT NULL, updated_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.site_assets TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_assets TO authenticated;
GRANT ALL ON public.site_assets TO service_role;
ALTER TABLE public.site_assets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Site assets public read" ON public.site_assets;
CREATE POLICY "Site assets public read" ON public.site_assets FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admin manage site assets" ON public.site_assets;
CREATE POLICY "Admin manage site assets" ON public.site_assets FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_site_assets_updated_at ON public.site_assets;
CREATE TRIGGER update_site_assets_updated_at BEFORE UPDATE ON public.site_assets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.payment_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  method TEXT NOT NULL, name TEXT NOT NULL, value TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.payment_credentials TO authenticated;
GRANT ALL ON public.payment_credentials TO service_role;
ALTER TABLE public.payment_credentials ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin only payment credentials" ON public.payment_credentials;
CREATE POLICY "Admin only payment credentials" ON public.payment_credentials FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_payment_credentials_updated_at ON public.payment_credentials;
CREATE TRIGGER update_payment_credentials_updated_at BEFORE UPDATE ON public.payment_credentials FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.content_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_key TEXT UNIQUE NOT NULL, title TEXT, content TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.content_blocks TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.content_blocks TO authenticated;
GRANT ALL ON public.content_blocks TO service_role;
ALTER TABLE public.content_blocks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Content blocks public read" ON public.content_blocks;
CREATE POLICY "Content blocks public read" ON public.content_blocks FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admin manage content blocks" ON public.content_blocks;
CREATE POLICY "Admin manage content blocks" ON public.content_blocks FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_content_blocks_updated_at ON public.content_blocks;
CREATE TRIGGER update_content_blocks_updated_at BEFORE UPDATE ON public.content_blocks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  package_id UUID REFERENCES public.uc_packages(id),
  amount INTEGER NOT NULL, price NUMERIC NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  payment_method TEXT, transaction_id TEXT, player_id TEXT, server_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.orders TO authenticated;
GRANT ALL ON public.orders TO service_role;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users view own orders" ON public.orders;
CREATE POLICY "Users view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users create own orders" ON public.orders;
CREATE POLICY "Users create own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins view all orders" ON public.orders;
CREATE POLICY "Admins view all orders" ON public.orders FOR SELECT USING (public.has_role(auth.uid(), 'admin'));
DROP POLICY IF EXISTS "Admins modify all orders" ON public.orders;
CREATE POLICY "Admins modify all orders" ON public.orders FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.admin_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL, action TEXT NOT NULL,
  target_type TEXT, target_id TEXT, details JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.admin_logs TO authenticated;
GRANT ALL ON public.admin_logs TO service_role;
ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin only logs read" ON public.admin_logs;
CREATE POLICY "Admin only logs read" ON public.admin_logs FOR SELECT USING (public.has_role(auth.uid(), 'admin'));
DROP POLICY IF EXISTS "Admin only logs insert" ON public.admin_logs;
CREATE POLICY "Admin only logs insert" ON public.admin_logs FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE OR REPLACE FUNCTION public.log_admin_action(p_action text, p_target_type text DEFAULT NULL, p_target_id text DEFAULT NULL, p_details jsonb DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN INSERT INTO public.admin_logs (admin_id, action, target_type, target_id, details) VALUES (auth.uid(), p_action, p_target_type, p_target_id, p_details); END; $$;

CREATE OR REPLACE FUNCTION public.grant_role_by_email(user_email text, target_role public.app_role)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE uid uuid;
BEGIN
  SELECT user_id INTO uid FROM public.profiles WHERE lower(email) = lower(user_email);
  IF uid IS NULL THEN RETURN false; END IF;
  INSERT INTO public.user_roles (user_id, role) VALUES (uid, target_role) ON CONFLICT DO NOTHING;
  RETURN true;
END; $$;

CREATE OR REPLACE FUNCTION public.revoke_role_by_email(user_email text, target_role public.app_role)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE uid uuid;
BEGIN
  SELECT user_id INTO uid FROM public.profiles WHERE lower(email) = lower(user_email);
  IF uid IS NULL THEN RETURN false; END IF;
  DELETE FROM public.user_roles WHERE user_id = uid AND role = target_role;
  RETURN true;
END; $$;

CREATE OR REPLACE FUNCTION public.list_admins()
RETURNS TABLE(user_id uuid, email text, since timestamptz)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT ur.user_id, p.email, ur.created_at FROM public.user_roles ur JOIN public.profiles p ON p.user_id = ur.user_id WHERE ur.role = 'admin' ORDER BY ur.created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.list_users_with_admin()
RETURNS TABLE(user_id uuid, email text, is_admin boolean)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT p.user_id, p.email, EXISTS (SELECT 1 FROM public.user_roles ur WHERE ur.user_id = p.user_id AND ur.role = 'admin') FROM public.profiles p ORDER BY p.created_at DESC;
$$;

CREATE TABLE IF NOT EXISTS public.page_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  path TEXT NOT NULL, user_agent TEXT, ip_address TEXT, referrer TEXT,
  user_id UUID, session_id TEXT, country_name TEXT, device_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.page_views TO anon;
GRANT SELECT, INSERT ON public.page_views TO authenticated;
GRANT ALL ON public.page_views TO service_role;
ALTER TABLE public.page_views ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone insert page views" ON public.page_views;
CREATE POLICY "Anyone insert page views" ON public.page_views FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Admins read page views" ON public.page_views;
CREATE POLICY "Admins read page views" ON public.page_views FOR SELECT USING (public.has_role(auth.uid(), 'admin'));

CREATE TABLE IF NOT EXISTS public.live_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id TEXT NOT NULL UNIQUE,
  user_id UUID, path TEXT NOT NULL, user_agent TEXT,
  last_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.live_users TO anon;
GRANT SELECT, INSERT, UPDATE ON public.live_users TO authenticated;
GRANT ALL ON public.live_users TO service_role;
ALTER TABLE public.live_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone insert live users" ON public.live_users;
CREATE POLICY "Anyone insert live users" ON public.live_users FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Anyone update live users" ON public.live_users;
CREATE POLICY "Anyone update live users" ON public.live_users FOR UPDATE USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins read live users" ON public.live_users;
CREATE POLICY "Admins read live users" ON public.live_users FOR SELECT USING (public.has_role(auth.uid(), 'admin'));

CREATE OR REPLACE FUNCTION public.cleanup_live_users() RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$ DELETE FROM public.live_users WHERE last_seen < now() - INTERVAL '5 minutes'; $$;

CREATE OR REPLACE FUNCTION public.get_page_views_analytics(days_back INTEGER DEFAULT 7)
RETURNS TABLE(total_views BIGINT, unique_visitors BIGINT, top_pages JSONB)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  WITH s AS (SELECT COUNT(*)::bigint tv, COUNT(DISTINCT COALESCE(user_id::text, session_id))::bigint uv FROM public.page_views WHERE created_at >= now() - (days_back||' days')::interval),
  tp AS (SELECT path, COUNT(*) v FROM public.page_views WHERE created_at >= now() - (days_back||' days')::interval GROUP BY path ORDER BY v DESC LIMIT 10)
  SELECT s.tv, s.uv, (SELECT jsonb_agg(jsonb_build_object('path', path, 'views', v)) FROM tp) FROM s;
$$;

CREATE TABLE IF NOT EXISTS public.analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_address TEXT NOT NULL,
  visit_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  date DATE NOT NULL DEFAULT CURRENT_DATE
);
GRANT INSERT ON public.analytics TO anon;
GRANT SELECT, INSERT ON public.analytics TO authenticated;
GRANT ALL ON public.analytics TO service_role;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public insert analytics" ON public.analytics;
CREATE POLICY "Public insert analytics" ON public.analytics FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Admins read analytics" ON public.analytics;
CREATE POLICY "Admins read analytics" ON public.analytics FOR SELECT USING (public.has_role(auth.uid(), 'admin'));

CREATE TABLE IF NOT EXISTS public.pubg_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL, description TEXT, price NUMERIC NOT NULL,
  video_url TEXT, thumbnail_url TEXT,
  login_email TEXT, login_password TEXT, recovery_info TEXT,
  status TEXT NOT NULL DEFAULT 'available',
  video_duration INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.pubg_accounts TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pubg_accounts TO authenticated;
GRANT ALL ON public.pubg_accounts TO service_role;
ALTER TABLE public.pubg_accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public view available pubg" ON public.pubg_accounts;
CREATE POLICY "Public view available pubg" ON public.pubg_accounts FOR SELECT USING (status = 'available');
DROP POLICY IF EXISTS "Admins manage pubg" ON public.pubg_accounts;
CREATE POLICY "Admins manage pubg" ON public.pubg_accounts FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_pubg_accounts_updated_at ON public.pubg_accounts;
CREATE TRIGGER update_pubg_accounts_updated_at BEFORE UPDATE ON public.pubg_accounts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.pubg_account_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  account_id UUID REFERENCES public.pubg_accounts(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  transaction_id TEXT, payment_method TEXT,
  status TEXT NOT NULL DEFAULT 'pending', buyer_email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.pubg_account_orders TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pubg_account_orders TO authenticated;
GRANT ALL ON public.pubg_account_orders TO service_role;
ALTER TABLE public.pubg_account_orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone create pubg orders" ON public.pubg_account_orders;
CREATE POLICY "Anyone create pubg orders" ON public.pubg_account_orders FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users view own pubg orders" ON public.pubg_account_orders;
CREATE POLICY "Users view own pubg orders" ON public.pubg_account_orders FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins view all pubg orders" ON public.pubg_account_orders;
CREATE POLICY "Admins view all pubg orders" ON public.pubg_account_orders FOR SELECT USING (public.has_role(auth.uid(), 'admin'));
DROP POLICY IF EXISTS "Admins update pubg orders" ON public.pubg_account_orders;
CREATE POLICY "Admins update pubg orders" ON public.pubg_account_orders FOR UPDATE USING (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_pubg_account_orders_updated_at ON public.pubg_account_orders;
CREATE TRIGGER update_pubg_account_orders_updated_at BEFORE UPDATE ON public.pubg_account_orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.whatsapp_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.whatsapp_settings TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.whatsapp_settings TO authenticated;
GRANT ALL ON public.whatsapp_settings TO service_role;
ALTER TABLE public.whatsapp_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public view whatsapp settings" ON public.whatsapp_settings;
CREATE POLICY "Public view whatsapp settings" ON public.whatsapp_settings FOR SELECT USING (true);
DROP POLICY IF EXISTS "Admin manage whatsapp settings" ON public.whatsapp_settings;
CREATE POLICY "Admin manage whatsapp settings" ON public.whatsapp_settings FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
DROP TRIGGER IF EXISTS update_whatsapp_settings_updated_at ON public.whatsapp_settings;
CREATE TRIGGER update_whatsapp_settings_updated_at BEFORE UPDATE ON public.whatsapp_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.blogs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL, slug TEXT NOT NULL UNIQUE,
  excerpt TEXT, content TEXT NOT NULL, featured_image_url TEXT,
  author TEXT DEFAULT 'Midasbuy Team', published BOOLEAN DEFAULT false,
  meta_title TEXT, meta_description TEXT, tags TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.blogs TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.blogs TO authenticated;
GRANT ALL ON public.blogs TO service_role;
ALTER TABLE public.blogs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Published blogs public" ON public.blogs;
CREATE POLICY "Published blogs public" ON public.blogs FOR SELECT USING (published = true);
DROP POLICY IF EXISTS "Admins manage blogs" ON public.blogs;
CREATE POLICY "Admins manage blogs" ON public.blogs FOR ALL USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE OR REPLACE FUNCTION public.generate_slug_from_title() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.slug IS NULL OR NEW.slug = '' THEN
    NEW.slug := lower(regexp_replace(regexp_replace(NEW.title, '[^a-zA-Z0-9\s]', '', 'g'), '\s+', '-', 'g'));
  END IF;
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS generate_blog_slug ON public.blogs;
CREATE TRIGGER generate_blog_slug BEFORE INSERT OR UPDATE ON public.blogs FOR EACH ROW EXECUTE FUNCTION public.generate_slug_from_title();
DROP TRIGGER IF EXISTS update_blogs_updated_at ON public.blogs;
CREATE TRIGGER update_blogs_updated_at BEFORE UPDATE ON public.blogs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Storage RLS
DROP POLICY IF EXISTS "Public read app buckets" ON storage.objects;
CREATE POLICY "Public read app buckets" ON storage.objects FOR SELECT USING (bucket_id IN ('assets','pubg-accounts','blog-images'));
DROP POLICY IF EXISTS "Admins manage app buckets" ON storage.objects;
CREATE POLICY "Admins manage app buckets" ON storage.objects FOR ALL USING (bucket_id IN ('assets','pubg-accounts','blog-images') AND public.has_role(auth.uid(), 'admin')) WITH CHECK (bucket_id IN ('assets','pubg-accounts','blog-images') AND public.has_role(auth.uid(), 'admin'));

INSERT INTO public.whatsapp_settings (phone_number, is_active) SELECT '+447476966269', true WHERE NOT EXISTS (SELECT 1 FROM public.whatsapp_settings);
