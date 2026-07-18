-- Fix Data-API GRANTs on tables used by refund/order/inquiry flows and update WhatsApp settings

-- Orders: authenticated users insert/view own, admins manage all; anon should not read
GRANT SELECT, INSERT, UPDATE, DELETE ON public.orders TO authenticated;
GRANT ALL ON public.orders TO service_role;

-- Customer inquiries: anyone (anon) may INSERT via public form; admins manage
GRANT SELECT, INSERT ON public.customer_inquiries TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.customer_inquiries TO authenticated;
GRANT ALL ON public.customer_inquiries TO service_role;

-- Inquiry email log: admin-only via policies, edge functions use service role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.inquiry_email_log TO authenticated;
GRANT ALL ON public.inquiry_email_log TO service_role;

-- Admin notification history: insert from public flows allowed, admin reads
GRANT SELECT, INSERT ON public.admin_notification_history TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.admin_notification_history TO authenticated;
GRANT ALL ON public.admin_notification_history TO service_role;

-- Notifications & user_notifications used by admin panel & refund flow
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_notifications TO authenticated;
GRANT ALL ON public.user_notifications TO service_role;

-- Update WhatsApp support phone to new number
UPDATE public.whatsapp_settings SET phone_number = '+14502324500', updated_at = now();
