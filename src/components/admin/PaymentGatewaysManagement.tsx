import { useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAllGateways, PaymentGateway } from '@/hooks/usePaymentGateways';
import { Switch } from '@/components/ui/switch';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { useToast } from '@/hooks/use-toast';
import { CreditCard, Upload, Loader2, Trash2 } from 'lucide-react';

export default function PaymentGatewaysManagement() {
  const { gateways, loading, refetch } = useAllGateways();
  const { toast } = useToast();
  const [uploadingId, setUploadingId] = useState<string | null>(null);
  const [savingId, setSavingId] = useState<string | null>(null);

  const [newCode, setNewCode] = useState('');
  const [newName, setNewName] = useState('');
  const [creating, setCreating] = useState(false);

  const toggleEnabled = async (g: PaymentGateway, enabled: boolean) => {
    setSavingId(g.id);
    const { error } = await supabase
      .from('payment_gateways')
      .update({ is_enabled: enabled })
      .eq('id', g.id);
    setSavingId(null);
    if (error) {
      toast({ variant: 'destructive', title: 'Update failed', description: error.message });
    } else {
      toast({
        title: enabled ? 'Gateway enabled' : 'Gateway disabled',
        description: `${g.name} is now ${enabled ? 'live on checkout' : 'hidden from checkout'}.`,
      });
      refetch();
    }
  };

  const uploadLogo = async (g: PaymentGateway, file: File) => {
    setUploadingId(g.id);
    const ext = file.name.split('.').pop();
    const fileName = `payment-logos/${g.code}-${Date.now()}.${ext}`;
    const { error: upErr } = await supabase.storage
      .from('site-assets')
      .upload(fileName, file, { upsert: true });
    if (upErr) {
      setUploadingId(null);
      toast({ variant: 'destructive', title: 'Upload failed', description: upErr.message });
      return;
    }
    const { data } = supabase.storage.from('site-assets').getPublicUrl(fileName);
    const { error: updErr } = await supabase
      .from('payment_gateways')
      .update({ logo_url: data.publicUrl })
      .eq('id', g.id);
    setUploadingId(null);
    if (updErr) {
      toast({ variant: 'destructive', title: 'Save failed', description: updErr.message });
    } else {
      toast({ title: 'Logo updated', description: g.name });
      refetch();
    }
  };

  const createGateway = async () => {
    if (!newCode.trim() || !newName.trim()) {
      toast({ variant: 'destructive', title: 'Missing fields', description: 'Enter code and name.' });
      return;
    }
    setCreating(true);
    const { error } = await supabase
      .from('payment_gateways')
      .insert({
        code: newCode.trim().toLowerCase(),
        name: newName.trim(),
        is_enabled: false,
        sort_order: gateways.length + 1,
      });
    setCreating(false);
    if (error) {
      toast({ variant: 'destructive', title: 'Create failed', description: error.message });
    } else {
      setNewCode('');
      setNewName('');
      toast({ title: 'Gateway added', description: 'Disabled by default — enable when ready.' });
      refetch();
    }
  };

  const deleteGateway = async (g: PaymentGateway) => {
    if (!confirm(`Delete "${g.name}"? This removes it from checkout permanently.`)) return;
    const { error } = await supabase.from('payment_gateways').delete().eq('id', g.id);
    if (error) toast({ variant: 'destructive', title: 'Delete failed', description: error.message });
    else { toast({ title: 'Deleted' }); refetch(); }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-white flex items-center gap-2">
          <CreditCard className="w-7 h-7" />
          Payment Gateways
        </h1>
        <p className="text-gray-400 mt-1">
          Enable/disable payment methods shown on checkout. Disabled gateways are hidden from customers
          and rejected server-side.
        </p>
      </div>

      {loading ? (
        <div className="flex items-center gap-2 text-gray-400"><Loader2 className="w-4 h-4 animate-spin" /> Loading gateways…</div>
      ) : (
        <div className="grid gap-4">
          {gateways.map((g) => (
            <div key={g.id} className="bg-[#1c2133] border border-[#2a3042] rounded-xl p-4 flex items-center gap-4 flex-wrap">
              <div className="w-20 h-14 bg-[#0f1220] rounded-lg flex items-center justify-center overflow-hidden shrink-0">
                {g.logo_url ? (
                  <img src={g.logo_url} alt={g.name} className="w-full h-full object-contain p-1" />
                ) : (
                  <CreditCard className="w-6 h-6 text-gray-500" />
                )}
              </div>
              <div className="flex-1 min-w-[180px]">
                <div className="text-white font-semibold">{g.name}</div>
                <div className="text-xs text-gray-500 font-mono">code: {g.code}</div>
              </div>
              <div className="flex items-center gap-3">
                <Label htmlFor={`logo-${g.id}`} className="cursor-pointer">
                  <div className="flex items-center gap-1 text-xs px-3 py-2 rounded-md bg-[#252a3d] hover:bg-[#2f3550] text-white transition">
                    {uploadingId === g.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <Upload className="w-3 h-3" />}
                    {uploadingId === g.id ? 'Uploading…' : 'Logo'}
                  </div>
                  <input
                    id={`logo-${g.id}`}
                    type="file"
                    accept="image/*"
                    className="hidden"
                    disabled={uploadingId === g.id}
                    onChange={(e) => {
                      const f = e.target.files?.[0];
                      if (f) uploadLogo(g, f);
                      e.target.value = '';
                    }}
                  />
                </Label>
                <div className="flex items-center gap-2">
                  <span className={`text-xs ${g.is_enabled ? 'text-green-400' : 'text-gray-500'}`}>
                    {g.is_enabled ? 'Live' : 'Off'}
                  </span>
                  <Switch
                    checked={g.is_enabled}
                    disabled={savingId === g.id}
                    onCheckedChange={(v) => toggleEnabled(g, v)}
                  />
                </div>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => deleteGateway(g)}
                  className="text-red-400 hover:text-red-300 hover:bg-red-500/10"
                >
                  <Trash2 className="w-4 h-4" />
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="bg-[#1c2133] border border-[#2a3042] rounded-xl p-4 space-y-3">
        <h2 className="text-white font-semibold">Add new gateway</h2>
        <div className="grid md:grid-cols-3 gap-3">
          <div>
            <Label className="text-gray-300 text-xs">Code (unique, lowercase)</Label>
            <Input
              value={newCode}
              onChange={(e) => setNewCode(e.target.value)}
              placeholder="e.g. stripe, upi, paypal"
              className="bg-[#0f1220] border-[#2a3042] text-white"
            />
          </div>
          <div>
            <Label className="text-gray-300 text-xs">Display name</Label>
            <Input
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              placeholder="e.g. Stripe (Cards)"
              className="bg-[#0f1220] border-[#2a3042] text-white"
            />
          </div>
          <div className="flex items-end">
            <Button onClick={createGateway} disabled={creating} className="w-full">
              {creating ? <Loader2 className="w-4 h-4 animate-spin mr-2" /> : null}
              Add gateway
            </Button>
          </div>
        </div>
        <p className="text-xs text-gray-500">
          New gateways are added disabled. Enable the toggle once the payment integration is wired.
        </p>
      </div>
    </div>
  );
}
