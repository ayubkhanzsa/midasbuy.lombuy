-- ============================================================
-- Remaining tables (Batch 2 + 3 consolidated & cleaned)
-- ============================================================

-- WhatsApp conversations
CREATE TABLE IF NOT EXISTS public.whatsapp_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number TEXT NOT NULL UNIQUE,
  contact_name TEXT,
  profile_pic_url TEXT,
  is_active BOOLEAN DEFAULT true,
  last_message_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.whatsapp_conversations TO authenticated;
GRANT ALL ON public.whatsapp_conversations TO service_role;
ALTER TABLE public.whatsapp_conversations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins manage conversations" ON public.whatsapp_conversations;
CREATE POLICY "Admins manage conversations" ON public.whatsapp_conversations FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- WhatsApp messages
CREATE TABLE IF NOT EXISTS public.whatsapp_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.whatsapp_conversations(id) ON DELETE CASCADE,
  message_id TEXT,
  phone_number TEXT NOT NULL,
  message_text TEXT,
  message_type TEXT DEFAULT 'text',
  media_url TEXT,
  is_outgoing BOOLEAN NOT NULL DEFAULT false,
  status TEXT DEFAULT 'sent',
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.whatsapp_messages TO authenticated;
GRANT ALL ON public.whatsapp_messages TO service_role;
ALTER TABLE public.whatsapp_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins manage messages" ON public.whatsapp_messages;
CREATE POLICY "Admins manage messages" ON public.whatsapp_messages FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- PUBG account credentials
CREATE TABLE IF NOT EXISTS public.pubg_account_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES public.pubg_accounts(id) ON DELETE CASCADE,
  login_email TEXT,
  login_password TEXT,
  recovery_info TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(account_id)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pubg_account_credentials TO authenticated;
GRANT ALL ON public.pubg_account_credentials TO service_role;
ALTER TABLE public.pubg_account_credentials ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins manage pubg credentials" ON public.pubg_account_credentials;
CREATE POLICY "Admins manage pubg credentials" ON public.pubg_account_credentials FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

CREATE OR REPLACE FUNCTION public.get_purchased_account_credentials(p_account_id UUID)
RETURNS TABLE(login_email TEXT, login_password TEXT, recovery_info TEXT)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.orders o WHERE o.user_id=auth.uid() AND o.status IN ('completed','paid')) THEN
    RAISE EXCEPTION 'Access denied: No valid purchase found';
  END IF;
  RETURN QUERY SELECT pac.login_email, pac.login_password, pac.recovery_info
    FROM public.pubg_account_credentials pac WHERE pac.account_id = p_account_id;
END; $$;

-- Site banners
CREATE TABLE IF NOT EXISTS public.site_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  banner_key TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  page_name TEXT NOT NULL,
  device_type TEXT NOT NULL DEFAULT 'both',
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER DEFAULT 0,
  position_x INTEGER DEFAULT 0,
  position_y INTEGER DEFAULT 0,
  light_effect BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.site_banners TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_banners TO authenticated;
GRANT ALL ON public.site_banners TO service_role;
ALTER TABLE public.site_banners ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "View active banners" ON public.site_banners;
CREATE POLICY "View active banners" ON public.site_banners FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "Admins manage banners" ON public.site_banners;
CREATE POLICY "Admins manage banners" ON public.site_banners FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- Chat history
CREATE TABLE IF NOT EXISTS public.chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  session_id TEXT,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.chat_history TO authenticated;
GRANT ALL ON public.chat_history TO service_role;
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users view own chat" ON public.chat_history;
CREATE POLICY "Users view own chat" ON public.chat_history FOR SELECT
  USING (auth.uid() = user_id OR has_role(auth.uid(),'admin'));
DROP POLICY IF EXISTS "Users insert own chat" ON public.chat_history;
CREATE POLICY "Users insert own chat" ON public.chat_history FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Page meta
CREATE TABLE IF NOT EXISTS public.page_meta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id TEXT UNIQUE NOT NULL,
  path TEXT,
  title TEXT,
  meta_title TEXT,
  meta_description TEXT,
  meta_keywords TEXT,
  canonical_url TEXT,
  og_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
GRANT SELECT ON public.page_meta TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.page_meta TO authenticated;
GRANT ALL ON public.page_meta TO service_role;
ALTER TABLE public.page_meta ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Page meta public read" ON public.page_meta;
CREATE POLICY "Page meta public read" ON public.page_meta FOR SELECT USING (true);
DROP POLICY IF EXISTS "Page meta admin write" ON public.page_meta;
CREATE POLICY "Page meta admin write" ON public.page_meta FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- Push subscriptions
CREATE TABLE IF NOT EXISTS public.push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  endpoint TEXT NOT NULL UNIQUE,
  p256dh TEXT,
  auth TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.push_subscriptions TO authenticated;
GRANT ALL ON public.push_subscriptions TO service_role;
ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own subs" ON public.push_subscriptions;
CREATE POLICY "Users manage own subs" ON public.push_subscriptions FOR ALL
  USING (auth.uid() = user_id OR has_role(auth.uid(),'admin'))
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'announcement',
  icon_url TEXT,
  action_url TEXT,
  sent_by UUID,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Notifs view auth" ON public.notifications;
CREATE POLICY "Notifs view auth" ON public.notifications FOR SELECT USING (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Notifs admin insert" ON public.notifications;
CREATE POLICY "Notifs admin insert" ON public.notifications FOR INSERT WITH CHECK (has_role(auth.uid(),'admin'));
DROP POLICY IF EXISTS "Notifs admin delete" ON public.notifications;
CREATE POLICY "Notifs admin delete" ON public.notifications FOR DELETE USING (has_role(auth.uid(),'admin'));

-- User notifications
CREATE TABLE IF NOT EXISTS public.user_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  read BOOLEAN NOT NULL DEFAULT false,
  read_at TIMESTAMPTZ,
  delivered BOOLEAN NOT NULL DEFAULT false,
  delivered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_notifications TO authenticated;
GRANT ALL ON public.user_notifications TO service_role;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users view own notifs" ON public.user_notifications;
CREATE POLICY "Users view own notifs" ON public.user_notifications FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users update own notifs" ON public.user_notifications;
CREATE POLICY "Users update own notifs" ON public.user_notifications FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins insert user notifs" ON public.user_notifications;
CREATE POLICY "Admins insert user notifs" ON public.user_notifications FOR INSERT WITH CHECK (has_role(auth.uid(),'admin'));

-- Admin notification history
CREATE TABLE IF NOT EXISTS public.admin_notification_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  order_id TEXT,
  package_name TEXT,
  price NUMERIC,
  player_id TEXT,
  sent_to_count INTEGER DEFAULT 0,
  total_admins INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.admin_notification_history TO authenticated;
GRANT ALL ON public.admin_notification_history TO service_role;
ALTER TABLE public.admin_notification_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin history admin read" ON public.admin_notification_history;
CREATE POLICY "Admin history admin read" ON public.admin_notification_history FOR SELECT USING (has_role(auth.uid(),'admin'));
DROP POLICY IF EXISTS "Admin history insert" ON public.admin_notification_history;
CREATE POLICY "Admin history insert" ON public.admin_notification_history FOR INSERT WITH CHECK (true);

-- Customer inquiries
CREATE TABLE IF NOT EXISTS public.customer_inquiries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  subject TEXT,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.customer_inquiries TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.customer_inquiries TO authenticated;
GRANT ALL ON public.customer_inquiries TO service_role;
ALTER TABLE public.customer_inquiries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone submit inquiry" ON public.customer_inquiries;
CREATE POLICY "Anyone submit inquiry" ON public.customer_inquiries FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Admins manage inquiries" ON public.customer_inquiries;
CREATE POLICY "Admins manage inquiries" ON public.customer_inquiries FOR ALL TO authenticated
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

CREATE TABLE IF NOT EXISTS public.customer_inquiries_archive (LIKE public.customer_inquiries INCLUDING ALL);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.customer_inquiries_archive TO authenticated;
GRANT ALL ON public.customer_inquiries_archive TO service_role;
ALTER TABLE public.customer_inquiries_archive ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins archive inquiries" ON public.customer_inquiries_archive;
CREATE POLICY "Admins archive inquiries" ON public.customer_inquiries_archive FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- Inquiry email log
CREATE TABLE IF NOT EXISTS public.inquiry_email_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inquiry_id UUID REFERENCES public.customer_inquiries(id) ON DELETE CASCADE,
  email_to TEXT NOT NULL,
  subject TEXT,
  body TEXT,
  status TEXT DEFAULT 'sent',
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.inquiry_email_log TO authenticated;
GRANT ALL ON public.inquiry_email_log TO service_role;
ALTER TABLE public.inquiry_email_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins view email log" ON public.inquiry_email_log;
CREATE POLICY "Admins view email log" ON public.inquiry_email_log FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- Orders archive
CREATE TABLE IF NOT EXISTS public.orders_archive (LIKE public.orders INCLUDING DEFAULTS);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.orders_archive TO authenticated;
GRANT ALL ON public.orders_archive TO service_role;
ALTER TABLE public.orders_archive ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins archive orders" ON public.orders_archive;
CREATE POLICY "Admins archive orders" ON public.orders_archive FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- Redeem codes
CREATE TABLE IF NOT EXISTS public.redeem_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  redeem_code TEXT NOT NULL UNIQUE,
  order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  package_name TEXT,
  uc_amount INTEGER,
  used BOOLEAN NOT NULL DEFAULT false,
  used_by UUID,
  used_at TIMESTAMPTZ,
  expire_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.redeem_codes TO authenticated;
GRANT ALL ON public.redeem_codes TO service_role;
ALTER TABLE public.redeem_codes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins manage redeem codes" ON public.redeem_codes;
CREATE POLICY "Admins manage redeem codes" ON public.redeem_codes FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
DROP POLICY IF EXISTS "Users view own redeem codes" ON public.redeem_codes;
CREATE POLICY "Users view own redeem codes" ON public.redeem_codes FOR SELECT
  USING (used_by = auth.uid() OR EXISTS(SELECT 1 FROM public.orders o WHERE o.id = redeem_codes.order_id AND o.user_id = auth.uid()));

CREATE TABLE IF NOT EXISTS public.redeem_codes_archive (LIKE public.redeem_codes INCLUDING DEFAULTS);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.redeem_codes_archive TO authenticated;
GRANT ALL ON public.redeem_codes_archive TO service_role;
ALTER TABLE public.redeem_codes_archive ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins archive codes" ON public.redeem_codes_archive;
CREATE POLICY "Admins archive codes" ON public.redeem_codes_archive FOR ALL
  USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));

-- Saved cards
CREATE TABLE IF NOT EXISTS public.saved_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  card_type TEXT,
  last_four TEXT NOT NULL,
  card_holder_name TEXT,
  expiry_month INTEGER,
  expiry_year INTEGER,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.saved_cards TO authenticated;
GRANT ALL ON public.saved_cards TO service_role;
ALTER TABLE public.saved_cards ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own cards" ON public.saved_cards;
CREATE POLICY "Users manage own cards" ON public.saved_cards FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Realtime for orders (safe)
ALTER TABLE public.orders REPLICA IDENTITY FULL;
DO $realtime$ BEGIN
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.orders; EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.whatsapp_conversations; EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.whatsapp_messages; EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.user_notifications; EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.customer_inquiries; EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN NULL; END;
END $realtime$;

-- Updated_at triggers
CREATE OR REPLACE TRIGGER trg_wa_conv_upd BEFORE UPDATE ON public.whatsapp_conversations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER trg_pubg_cred_upd BEFORE UPDATE ON public.pubg_account_credentials FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER trg_site_banners_upd BEFORE UPDATE ON public.site_banners FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER trg_page_meta_upd BEFORE UPDATE ON public.page_meta FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER trg_push_subs_upd BEFORE UPDATE ON public.push_subscriptions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER trg_inquiries_upd BEFORE UPDATE ON public.customer_inquiries FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE TRIGGER trg_redeem_upd BEFORE UPDATE ON public.redeem_codes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();