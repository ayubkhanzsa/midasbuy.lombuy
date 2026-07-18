-- orders extras
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS currency_code TEXT DEFAULT 'USD',
  ADD COLUMN IF NOT EXISTS email_sent_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS product_type TEXT,
  ADD COLUMN IF NOT EXISTS product_name TEXT,
  ADD COLUMN IF NOT EXISTS product_amount TEXT;

ALTER TABLE public.orders_archive
  ADD COLUMN IF NOT EXISTS archived_reason TEXT,
  ADD COLUMN IF NOT EXISTS email_sent_at TIMESTAMPTZ;

-- redeem_codes extras
ALTER TABLE public.redeem_codes
  ADD COLUMN IF NOT EXISTS player_id TEXT,
  ADD COLUMN IF NOT EXISTS username TEXT,
  ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS reviewed_by UUID,
  ADD COLUMN IF NOT EXISTS notes TEXT,
  ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- Allow users to insert their own redeem submissions
DROP POLICY IF EXISTS "Users insert own redeem submissions" ON public.redeem_codes;
CREATE POLICY "Users insert own redeem submissions" ON public.redeem_codes FOR INSERT TO authenticated
  WITH CHECK (used_by = auth.uid() OR used_by IS NULL);

ALTER TABLE public.redeem_codes_archive
  ADD COLUMN IF NOT EXISTS player_id TEXT,
  ADD COLUMN IF NOT EXISTS username TEXT,
  ADD COLUMN IF NOT EXISTS status TEXT,
  ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS reviewed_by UUID,
  ADD COLUMN IF NOT EXISTS notes TEXT,
  ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- inquiry_email_log
ALTER TABLE public.inquiry_email_log ADD COLUMN IF NOT EXISTS template_type TEXT;

-- log_admin_action overload with p_admin_id
CREATE OR REPLACE FUNCTION public.log_admin_action(
  p_admin_id UUID,
  p_action TEXT,
  p_target_type TEXT DEFAULT NULL,
  p_target_id TEXT DEFAULT NULL,
  p_details JSONB DEFAULT NULL
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.admin_logs (admin_id, action, target_type, target_id, details)
  VALUES (p_admin_id, p_action, p_target_type, p_target_id, p_details);
END; $$;

-- assign_default_role
CREATE OR REPLACE FUNCTION public.assign_default_role(p_user_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.user_roles(user_id, role) VALUES (p_user_id, 'user') ON CONFLICT DO NOTHING;
END; $$;

-- submit_redeem_code (atomic user submission with duplicate check)
CREATE OR REPLACE FUNCTION public.submit_redeem_code(
  p_redeem_code TEXT,
  p_player_id TEXT DEFAULT NULL,
  p_username TEXT DEFAULT NULL,
  p_package_name TEXT DEFAULT NULL,
  p_uc_amount INTEGER DEFAULT NULL
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE existing UUID;
BEGIN
  IF auth.uid() IS NULL THEN RETURN jsonb_build_object('success', false, 'duplicate', false, 'status', 'unauthenticated'); END IF;
  SELECT id INTO existing FROM public.redeem_codes WHERE redeem_code = p_redeem_code LIMIT 1;
  IF existing IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'duplicate', true, 'status', 'already_submitted');
  END IF;
  INSERT INTO public.redeem_codes(redeem_code, player_id, username, package_name, uc_amount, used_by, status)
  VALUES (p_redeem_code, p_player_id, p_username, p_package_name, p_uc_amount, auth.uid(), 'pending');
  RETURN jsonb_build_object('success', true, 'duplicate', false, 'status', 'submitted');
END; $$;