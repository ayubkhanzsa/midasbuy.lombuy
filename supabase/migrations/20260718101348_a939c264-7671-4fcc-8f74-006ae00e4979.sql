
-- payment_logs
CREATE TABLE IF NOT EXISTS public.payment_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gateway TEXT,
  transaction_id TEXT,
  order_id UUID,
  payload JSONB,
  status TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.payment_logs TO authenticated;
GRANT ALL ON public.payment_logs TO service_role;
ALTER TABLE public.payment_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view payment logs" ON public.payment_logs FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE INDEX IF NOT EXISTS payment_logs_order_idx ON public.payment_logs(order_id);
CREATE INDEX IF NOT EXISTS payment_logs_tx_idx ON public.payment_logs(transaction_id);

-- pubg_uc_page_content
CREATE TABLE IF NOT EXISTS public.pubg_uc_page_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_key TEXT NOT NULL UNIQUE,
  title TEXT,
  content TEXT,
  image_url TEXT,
  order_position INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
GRANT SELECT ON public.pubg_uc_page_content TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.pubg_uc_page_content TO authenticated;
GRANT ALL ON public.pubg_uc_page_content TO service_role;
ALTER TABLE public.pubg_uc_page_content ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view active content" ON public.pubg_uc_page_content FOR SELECT USING (active = true OR public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert content" ON public.pubg_uc_page_content FOR INSERT TO authenticated WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update content" ON public.pubg_uc_page_content FOR UPDATE TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete content" ON public.pubg_uc_page_content FOR DELETE TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER update_pubg_uc_page_content_updated_at BEFORE UPDATE ON public.pubg_uc_page_content FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
