import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

const root = path.resolve(process.argv[2] || "dist");
const port = Number(process.argv[3] || process.env.PORT || 3000);
const startedAt = new Date().toISOString();

const mime = { ".html": "text/html; charset=utf-8", ".js": "application/javascript; charset=utf-8", ".css": "text/css; charset=utf-8", ".json": "application/json; charset=utf-8", ".svg": "image/svg+xml", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp", ".ico": "image/x-icon", ".woff": "font/woff", ".woff2": "font/woff2" };

function walk(dir, acc = []) {
  if (!fs.existsSync(dir)) return acc;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, acc); else acc.push(full);
  }
  return acc;
}

function healthPayload() {
  const indexPath = path.join(root, "index.html");
  const exists = fs.existsSync(indexPath);
  const files = walk(root);
  const index = exists ? fs.readFileSync(indexPath) : Buffer.from("");
  const stat = exists ? fs.statSync(indexPath) : null;
  return {
    status: exists ? "ok" : "missing_index",
    served_by: "deployhub-node-static",
    root,
    index_html: {
      exists,
      size: exists ? index.length : 0,
      sha256: exists ? crypto.createHash("sha256").update(index).digest("hex") : "missing",
      mtime: stat ? stat.mtime.toISOString() : "missing",
      head: exists ? index.toString("utf8", 0, 240).replace(/\s+/g, " ") : ""
    },
    assets: { total: files.length, js: files.filter((f) => f.endsWith(".js")).length, css: files.filter((f) => f.endsWith(".css")).length },
    deploy: { version: process.env.DEPLOY_VERSION || "unknown", commit_sha: process.env.DEPLOY_COMMIT_SHA || "unknown", timestamp: process.env.DEPLOY_TIMESTAMP || "unknown" },
    generated_at: new Date().toISOString(),
    started_at: startedAt
  };
}

function send(res, status, body, type) {
  res.writeHead(status, { "Content-Type": type, "Cache-Control": "no-store", "X-DeployHub-Root": root, "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET,HEAD,OPTIONS", "Access-Control-Allow-Headers": "content-type" });
  res.end(body);
}

function resolveFile(urlPath) {
  const clean = decodeURIComponent((urlPath || "/").split("?")[0]);
  const rel = path.normalize(clean).replace(/^([.][.][\/])+/, "").replace(/^\/+/, "");
  return path.join(root, rel || "index.html");
}

http.createServer((req, res) => {
  if (req.method === "OPTIONS") return send(res, 204, "", "text/plain; charset=utf-8");
  const pathname = new URL(req.url || "/", "http://localhost").pathname;
  if (pathname === "/healthz/live") return send(res, 200, "ok\n", "text/plain; charset=utf-8");
  if (pathname === "/healthz" || pathname === "/healthz.json") return send(res, 200, JSON.stringify(healthPayload(), null, 2), "application/json; charset=utf-8");
  let file = resolveFile(pathname);
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) file = path.join(root, "index.html");
  if (!fs.existsSync(file)) return send(res, 404, "index.html not found\n", "text/plain; charset=utf-8");
  send(res, 200, fs.readFileSync(file), mime[path.extname(file).toLowerCase()] || "application/octet-stream");
}).listen(port, "0.0.0.0", () => console.log("[deployhub-health-server] serving " + root + " on 0.0.0.0:" + port));
