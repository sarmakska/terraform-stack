// Edge worker deployed by modules/cloudflare.
//
// It serves objects from the R2 bucket bound as ASSETS and uses the KV
// namespace bound as CACHE for a small read-through cache of object
// metadata. This is a real, deployable Worker, not a placeholder: it is
// uploaded verbatim by the cloudflare_workers_script resource and bound to
// the R2 bucket and KV namespace the module provisions.

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const key = url.pathname.replace(/^\/+/, "");

    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("method not allowed", { status: 405 });
    }

    if (key === "" || key === "health") {
      return new Response("ok", {
        status: 200,
        headers: { "content-type": "text/plain" },
      });
    }

    const cached = await env.CACHE.get(`meta:${key}`, { type: "json" });
    const object = await env.ASSETS.get(key);

    if (object === null) {
      return new Response("not found", { status: 404 });
    }

    if (cached === null) {
      await env.CACHE.put(
        `meta:${key}`,
        JSON.stringify({ size: object.size, etag: object.httpEtag }),
        { expirationTtl: 300 },
      );
    }

    const headers = new Headers();
    object.writeHttpMetadata(headers);
    headers.set("etag", object.httpEtag);
    headers.set("cache-control", "public, max-age=300");

    return new Response(request.method === "HEAD" ? null : object.body, {
      headers,
    });
  },
};
