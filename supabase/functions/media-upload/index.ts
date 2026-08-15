// ==============================================================================
// BHAGWA BACKEND EDGE FUNCTION: supabase/functions/media-upload/index.ts
// Secure Cloudflare R2 Direct Upload & Presigned URL Generator
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { contentType, filename, postId } = await req.json();

    if (!contentType || !filename) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: contentType, filename" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const r2AccountId = Deno.env.get("R2_ACCOUNT_ID") || "placeholder-account-id";
    const r2BucketName = Deno.env.get("R2_BUCKET_NAME") || "bhagwa-media";
    const r2PublicBaseUrl = Deno.env.get("R2_PUBLIC_BASE_URL") || "https://media.bhagwa.app";

    const datePrefix = new Date().toISOString().slice(0, 7).replace("-", "/"); // e.g. "2026/08"
    const uniqueId = crypto.randomUUID();
    const folder = contentType.toLowerCase() + "s"; // e.g. "wallpapers", "bhajans"
    const r2Key = `content/${folder}/${datePrefix}/${postId || "temp"}/${uniqueId}_${filename}`;
    const mediaUrl = `${r2PublicBaseUrl}/${r2Key}`;

    // Return direct upload target & metadata for client
    return new Response(
      JSON.stringify({
        r2Key,
        mediaUrl,
        uploadUrl: `https://${r2AccountId}.r2.cloudflarestorage.com/${r2BucketName}/${r2Key}`,
        message: "Presigned upload target generated successfully",
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: unknown) {
    const errorMessage = err instanceof Error ? err.message : "Internal Server Error";
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
