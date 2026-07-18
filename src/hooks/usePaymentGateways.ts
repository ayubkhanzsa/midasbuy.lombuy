import { useEffect, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';

export interface PaymentGateway {
  id: string;
  code: string;
  name: string;
  logo_url: string | null;
  is_enabled: boolean;
  sort_order: number;
}

/**
 * Fetch enabled payment gateways with realtime updates.
 * Used by checkout to hide/show payment methods based on admin toggles.
 */
export function useEnabledGateways() {
  const [gateways, setGateways] = useState<PaymentGateway[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    const fetchGateways = async () => {
      const { data } = await supabase
        .from('payment_gateways')
        .select('*')
        .eq('is_enabled', true)
        .order('sort_order');
      if (mounted && data) setGateways(data as PaymentGateway[]);
      if (mounted) setLoading(false);
    };

    fetchGateways();

    const channel = supabase
      .channel('payment-gateways-public')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'payment_gateways' },
        () => fetchGateways()
      )
      .subscribe();

    return () => {
      mounted = false;
      supabase.removeChannel(channel);
    };
  }, []);

  const enabled: Record<string, boolean> = {};
  gateways.forEach((g) => { enabled[g.code] = g.is_enabled; });

  const isEnabled = (code: string) => enabled[code] === true;

  return { gateways, isEnabled, loading };
}

/**
 * Fetch ALL gateways (enabled + disabled) for admin management.
 */
export function useAllGateways() {
  const [gateways, setGateways] = useState<PaymentGateway[]>([]);
  const [loading, setLoading] = useState(true);

  const refetch = async () => {
    const { data } = await supabase
      .from('payment_gateways')
      .select('*')
      .order('sort_order');
    if (data) setGateways(data as PaymentGateway[]);
    setLoading(false);
  };

  useEffect(() => {
    refetch();
    const channel = supabase
      .channel('payment-gateways-admin')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'payment_gateways' },
        () => refetch()
      )
      .subscribe();
    return () => { supabase.removeChannel(channel); };
  }, []);

  return { gateways, loading, refetch };
}
