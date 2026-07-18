
DROP POLICY IF EXISTS "site-assets public read" ON storage.objects;
DROP POLICY IF EXISTS "site-assets admin write" ON storage.objects;

CREATE POLICY "site-assets public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'site-assets');

CREATE POLICY "site-assets admin write"
ON storage.objects FOR ALL
USING (bucket_id = 'site-assets' AND public.has_role(auth.uid(), 'admin'))
WITH CHECK (bucket_id = 'site-assets' AND public.has_role(auth.uid(), 'admin'));

CREATE TABLE IF NOT EXISTS public.payment_gateways (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  logo_url TEXT,
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.payment_gateways TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.payment_gateways TO authenticated;
GRANT ALL ON public.payment_gateways TO service_role;

ALTER TABLE public.payment_gateways ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view enabled gateways" ON public.payment_gateways;
DROP POLICY IF EXISTS "Admins manage gateways" ON public.payment_gateways;

CREATE POLICY "Public can view enabled gateways"
ON public.payment_gateways FOR SELECT
USING (is_enabled = true OR public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins manage gateways"
ON public.payment_gateways FOR ALL
USING (public.has_role(auth.uid(), 'admin'))
WITH CHECK (public.has_role(auth.uid(), 'admin'));

DROP TRIGGER IF EXISTS trg_payment_gateways_updated ON public.payment_gateways;
CREATE TRIGGER trg_payment_gateways_updated
BEFORE UPDATE ON public.payment_gateways
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

INSERT INTO public.payment_gateways (code, name, logo_url, is_enabled, sort_order) VALUES
  ('card', 'Credit / Debit Card', null, true, 1),
  ('payfast', 'PayFast (JazzCash / EasyPaisa)', null, true, 2),
  ('binance', 'Binance Pay (Crypto)', null, true, 3)
ON CONFLICT (code) DO NOTHING;
