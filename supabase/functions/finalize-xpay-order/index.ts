import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { orderId } = await req.json();
    if (!orderId) {
      return new Response(JSON.stringify({ error: "orderId required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch by transaction_id first, then by id as fallback
    let { data: order } = await supabase
      .from("orders")
      .select("*")
      .eq("transaction_id", orderId)
      .maybeSingle();

    if (!order) {
      const { data: byId } = await supabase
        .from("orders")
        .select("*")
        .eq("id", orderId)
        .maybeSingle();
      order = byId;
    }

    if (!order) {
      return new Response(JSON.stringify({ error: "Order not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const isCardMethod =
      (order.payment_method || "").toLowerCase().includes("xpay") ||
      (order.payment_method || "").toLowerCase().includes("card");

    if (order.status === "pending" && isCardMethod) {
      // Business logic: card payments go to 'cancelled' (refund review flow)
      const { data: updated, error: updErr } = await supabase
        .from("orders")
        .update({ status: "cancelled", updated_at: new Date().toISOString() })
        .eq("id", order.id)
        .select()
        .single();

      if (updErr) {
        console.error("[finalize-xpay-order] update failed:", updErr);
        return new Response(JSON.stringify({ error: updErr.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      order = updated;

      // Fire-and-forget admin notification
      try {
        await supabase.functions.invoke("notify-admin-new-order", {
          body: {
            event_type: "new_order",
            order_details: {
              order_id: order.id,
              package_name: order.product_name,
              price: order.price,
              player_id: order.player_id,
              currency_code: order.currency_code || "PKR",
            },
          },
        });
      } catch (e) {
        console.error("notify-admin-new-order failed:", e);
      }
    }

    return new Response(JSON.stringify({ success: true, order }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: any) {
    console.error("[finalize-xpay-order] error:", error);
    return new Response(JSON.stringify({ error: error.message || "Internal error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
