// Supabase Edge Function: parklet-assistant
// Forwards the Design Assistant's requests to the Anthropic API so the key
// stays server-side. Deploy:
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//   supabase functions deploy parklet-assistant --no-verify-jwt
// Then paste https://<project>.supabase.co/functions/v1/parklet-assistant
// into the assistant's Proxy URL field and leave the API key blank.
//
// Hardening for anything public: remove --no-verify-jwt, have the page send
// the Supabase session token in an Authorization header, and rate-limit per user.

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return new Response("POST only", { status: 405, headers: CORS });

  const key = Deno.env.get("ANTHROPIC_API_KEY");
  if (!key) {
    return new Response(JSON.stringify({ error: { message: "ANTHROPIC_API_KEY secret is not set" } }),
      { status: 500, headers: { ...CORS, "content-type": "application/json" } });
  }

  const body = await req.text();
  const upstream = await fetch(ANTHROPIC_URL, {
    method: "POST",
    headers: { "content-type": "application/json", "x-api-key": key, "anthropic-version": "2023-06-01" },
    body,
  });
  return new Response(await upstream.text(), {
    status: upstream.status,
    headers: { ...CORS, "content-type": "application/json" },
  });
});
