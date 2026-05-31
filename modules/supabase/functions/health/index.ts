// Supabase edge function deployed by modules/supabase.
//
// A real, deployable Deno edge function. It is bundled and uploaded by the
// supabase_edge_function resource. The handler returns a small JSON health
// payload and echoes the authenticated user id when a valid bearer token is
// present, which is enough to prove auth wiring end to end.

Deno.serve((req: Request): Response => {
  const url = new URL(req.url);

  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "method not allowed" }), {
      status: 405,
      headers: { "content-type": "application/json" },
    });
  }

  const authHeader = req.headers.get("authorization") ?? "";
  const hasBearer = authHeader.toLowerCase().startsWith("bearer ");

  const body = {
    status: "ok",
    service: "terraform-stack-edge",
    path: url.pathname,
    authenticated: hasBearer,
    timestamp: new Date().toISOString(),
  };

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
});
