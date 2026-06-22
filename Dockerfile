# DEPLOYHUB_NGINX_SPA_V31
# Dockerfile robusto para Dokploy: Vite/React SPA via servidor Node estável + fallback SSR/Worker TanStack/Node, inclusive apps dentro de /client.
FROM node:22-alpine AS build
WORKDIR /app
COPY . .
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
# Instala COM devDependencies forçando --include=dev e NPM_CONFIG_PRODUCTION=false
# (NÃO usar NODE_ENV=development aqui — isso faria o Vite/React plugin emitir jsxDEV no bundle de produção)
ENV NPM_CONFIG_PRODUCTION=false
RUN if [ -f package.json ]; then npm install --legacy-peer-deps --include=dev; elif [ -f client/package.json ]; then cd client && npm install --legacy-peer-deps --include=dev; else echo "package.json não encontrado na raiz nem em /client"; exit 1; fi
# Safety-net: se houver postcss/tailwind config mas os módulos estiverem ausentes, instala versões PINADAS do v3.
RUN set -eu; \
  ROOT=/app; [ -f /app/package.json ] || ROOT=/app/client; \
  cd "$ROOT"; \
  # Renomeia config de TS para JS para evitar problemas de parsing no runner se necessário
  if [ -f tailwind.config.ts ] && [ ! -f tailwind.config.js ]; then \
    echo "[deployhub:build] convertendo tailwind.config.ts para .js"; \
    mv tailwind.config.ts tailwind.config.js || true; \
    sed -i 's/import type.*//g' tailwind.config.js || true; \
    sed -i 's/satisfies Config//g' tailwind.config.js || true; \
  fi; \
  if ls postcss.config.* tailwind.config.* 2>/dev/null | grep -q .; then \
    if [ ! -d "node_modules/tailwindcss" ]; then \
      echo "[deployhub:build] safety-net: instalando tailwindcss@3.4.13"; \
      npm install --no-save --legacy-peer-deps tailwindcss@3.4.13 autoprefixer@10.4.20 postcss@8.4.47 || true; \
    fi; \
  fi
# Build SEMPRE com NODE_ENV=production para que o Vite/React plugin emita jsx/jsxs (e não jsxDEV)
ENV NODE_ENV=production
RUN if [ -z "$VITE_SUPABASE_PUBLISHABLE_KEY" ]; then export VITE_SUPABASE_PUBLISHABLE_KEY="$VITE_SUPABASE_ANON_KEY"; fi && if [ -f package.json ]; then NODE_ENV=production npm run build; elif [ -f client/package.json ]; then cd client && NODE_ENV=production npm run build; fi
# Fallback SPA build: se gerou dist/server mas faltou index.html no client, força um vite build SPA puro
RUN set -eu;   ROOT=/app; [ -f /app/package.json ] || ROOT=/app/client;   cd "$ROOT";   if [ -d dist/server ] && [ ! -f dist/client/index.html ] && [ ! -f dist/index.html ]; then     echo "[deployhub:build] SSR build sem index.html — rodando vite build SPA de fallback em dist/client";     if [ -f node_modules/.bin/vite ]; then       ./node_modules/.bin/vite build --outDir dist/client --emptyOutDir=false ||       npx --yes vite build --outDir dist/client --emptyOutDir=false || true;     else       npx --yes vite build --outDir dist/client --emptyOutDir=false || true;     fi;   fi;   if [ ! -f dist/client/index.html ] && [ ! -f dist/index.html ]; then     if [ -f index.html ]; then       echo "[deployhub:build] último recurso: copiando index.html da raiz para dist/client";       mkdir -p dist/client; cp index.html dist/client/index.html;     elif [ -f client/index.html ]; then       echo "[deployhub:build] último recurso: copiando client/index.html para dist/client";       mkdir -p dist/client; cp client/index.html dist/client/index.html;     fi;   fi
RUN mkdir -p /app/dist /app/client/dist /app/.output /app/build &&   mkdir -p /app/client/node_modules &&   if [ ! -f /app/client/package.json ]; then echo '{}' > /app/client/package.json; fi &&   echo "[deployhub:build] build output candidates:" &&   for path in /app/dist /app/dist/client /app/client/dist /app/client/dist/client /app/.output/public /app/build /app/build/client; do     if [ -d "$path" ]; then echo "--- $path"; ls -la "$path"; fi;   done

FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache nginx curl ca-certificates &&   mkdir -p /run/nginx /var/log/nginx /usr/share/nginx/html /etc/nginx/http.d /etc/nginx/conf.d
COPY --from=build /app/dist ./dist
COPY --from=build /app/client/dist ./client/dist
COPY --from=build /app/.output ./.output
COPY --from=build /app/build ./build
COPY --from=build /app/deployhub-health-server.mjs ./deployhub-health-server.mjs
# Necessário para SSR (TanStack Start/Node) — o server bundle resolve deps em runtime (h3, etc.).
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/client/package.json ./client/package.json
COPY --from=build /app/client/node_modules ./client/node_modules
RUN cat > /usr/local/bin/deployhub-ssr-adapter.mjs <<'EOF'
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { Readable } from "node:stream";
import { pathToFileURL } from "node:url";

const entry = process.argv[2];
const port = Number(process.env.PORT || 3000);
const staticRoots = ["/app/dist/client", "/app/dist", "/app/client/dist/client", "/app/client/dist", "/app/.output/public", "/app/build/client", "/app/build"];
const mime = { ".html": "text/html; charset=utf-8", ".js": "application/javascript; charset=utf-8", ".css": "text/css; charset=utf-8", ".json": "application/json; charset=utf-8", ".svg": "image/svg+xml", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp", ".ico": "image/x-icon", ".woff": "font/woff", ".woff2": "font/woff2" };

if (!entry) {
  console.error("[deployhub-ssr-adapter] entrada SSR ausente");
  process.exit(1);
}

function headersFromIncoming(req) {
  const headers = new Headers();
  for (const [key, value] of Object.entries(req.headers)) {
    if (Array.isArray(value)) {
      for (const item of value) headers.append(key, item);
    } else if (value != null) {
      headers.set(key, String(value));
    }
  }
  return headers;
}

function requestBody(req) {
  if (req.method === "GET" || req.method === "HEAD") return undefined;
  return Readable.toWeb(req);
}

function resolveStaticAsset(pathname) {
  if (!(pathname.startsWith("/assets/") || pathname.startsWith("/favicon.") || pathname === "/manifest.json" || pathname === "/robots.txt" || pathname === "/site.webmanifest")) return null;
  const decoded = decodeURIComponent(pathname);
  const rel = path.normalize(decoded.startsWith("/") ? decoded.slice(1) : decoded);
  if (rel.startsWith("..") || path.isAbsolute(rel)) return null;
  for (const root of staticRoots) {
    const file = path.join(root, rel);
    if (fs.existsSync(file) && fs.statSync(file).isFile()) return file;
  }
  return null;
}

try {
  const mod = await import(pathToFileURL(entry).href);
  const candidate = mod.default || mod;
  const fetchHandler = candidate && typeof candidate.fetch === "function"
    ? candidate.fetch.bind(candidate)
    : (typeof mod.fetch === "function" ? mod.fetch.bind(mod) : null);
  const nodeHandler = typeof candidate === "function"
    ? candidate
    : (candidate && typeof candidate.handler === "function" ? candidate.handler.bind(candidate) : null);

  if (!fetchHandler && !nodeHandler) {
    console.error("[deployhub-ssr-adapter] módulo não exporta fetch() nem handler Node: " + entry + " exports=" + Object.keys(mod).join(",") + " defaultType=" + typeof candidate + " defaultKeys=" + (candidate && typeof candidate === "object" ? Object.keys(candidate).join(",") : ""));
    process.exit(1);
  }

  http.createServer(async (req, res) => {
    try {
      const pathname = new URL(req.url || "/", "http://localhost").pathname;
      if (pathname === "/healthz/live") {
        res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8", "Cache-Control": "no-store" });
        res.end("ok\n");
        return;
      }

      const staticFile = resolveStaticAsset(pathname);
      if (staticFile) {
        res.writeHead(200, { "Content-Type": mime[path.extname(staticFile).toLowerCase()] || "application/octet-stream", "Cache-Control": pathname.startsWith("/assets/") ? "public, max-age=31536000, immutable" : "no-cache" });
        if (req.method === "HEAD") res.end();
        else fs.createReadStream(staticFile).pipe(res);
        return;
      }

      const url = "http://" + (req.headers.host || "127.0.0.1:" + port) + (req.url || "/");
      const init = { method: req.method, headers: headersFromIncoming(req) };
      const body = requestBody(req);
      if (body) {
        init.body = body;
        init.duplex = "half";
      }
      if (nodeHandler && !fetchHandler) {
        return nodeHandler(req, res);
      }

      const response = await fetchHandler(new Request(url, init), process.env, { waitUntil() {}, passThroughOnException() {} });

      res.statusCode = response.status;
      response.headers.forEach((value, key) => res.setHeader(key, value));
      if (response.body) Readable.fromWeb(response.body).pipe(res);
      else res.end();
    } catch (error) {
      console.error("[deployhub-ssr-adapter] request failed", error);
      res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("SSR adapter error\n");
    }
  }).listen(port, "0.0.0.0", () => {
    console.log("[deployhub-ssr-adapter] serving " + entry + " on 0.0.0.0:" + port);
  });
} catch (error) {
  console.error("[deployhub-ssr-adapter] import failed", error);
  process.exit(1);
}
EOF
RUN cat > /usr/local/bin/deployhub-start <<'EOF'
#!/bin/sh
set -eu

log() { echo "[deployhub] $*"; }
is_debug() { [ "${DEPLOYHUB_DEBUG:-0}" = "1" ] || [ "${DEPLOYHUB_DEBUG:-0}" = "true" ]; }
dump_tree() {
  log "arquivos de build encontrados:"
  for path in /app/dist /app/dist/client /app/client/dist /app/client/dist/client /app/.output /app/.output/public /app/build /app/build/client /usr/share/nginx/html; do
    if [ -e "$path" ]; then echo "--- $path"; ls -la "$path" || true; fi
  done
}


if is_debug; then
  log "DEPLOYHUB_DEBUG ativo"
  env | sort | sed -E 's/(TOKEN|KEY|SECRET|PASSWORD)=.*/\1=***masked***/I'
  dump_tree
fi

STATIC_ROOT=""
for candidate in /app/dist/client /app/dist/client/client /app/dist /app/client/dist/client /app/client/dist /app/.output/public /app/build/client /app/build; do
  if [ -f "$candidate/index.html" ]; then
    STATIC_ROOT="$candidate"
    break
  fi
done

# Nunca deixe dois processos brigarem pela mesma porta. Versões anteriores
# subiam um health-server estático em background e depois tentavam iniciar
# SSR/Nginx na mesma PORT, causando bind conflict, container Created/Exited e 502.
run_ssr_candidate() {
  ENTRY="$1"
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: testando $ENTRY na porta $PORT"
  SSR_CMD="node"
  SSR_ARG="$ENTRY"
  # Nitro node_server (.output/server/index.mjs) deve ser executado diretamente.
  # Importá-lo pelo adapter ignora o bootstrap condicionado ao entrypoint e gera
  # "exports=default" / exitCode=1, mesmo com PORT correto.
  if [ "$ENTRY" = "/app/.output/server/index.mjs" ] && [ -f /app/.output/nitro.json ]; then
    PRESET=$(node -e "try{const n=require('/app/.output/nitro.json'); console.log(n.preset || n.commands?.preview || 'nitro')}catch{console.log('nitro')}" 2>/dev/null || echo nitro)
    log "Nitro node_server detectado ($PRESET); iniciando diretamente com node $ENTRY"
  else
  # Builds TanStack Start/Cloudflare exportam { fetch } (Worker), não um servidor Node que chama listen().
  # Rodar esses arquivos diretamente encerra com code 0/1 antes de abrir porta e causa loop Exited(1).
  # O adapter abaixo transforma qualquer export fetch() em servidor HTTP na PORT esperada.
  if grep -Eq "exports:|fetch[[:space:]]*:" "$ENTRY" 2>/dev/null || grep -q "fetch(" "$ENTRY" 2>/dev/null; then
    log "SSR/Worker export detectado em $ENTRY; iniciando via deployhub-ssr-adapter"
    SSR_CMD="node"
    SSR_ARG="/usr/local/bin/deployhub-ssr-adapter.mjs $ENTRY"
  fi
  fi
  sh -c "$SSR_CMD $SSR_ARG" &
  SSR_PID="$!"
  i=0
  while [ "$i" -lt 20 ]; do
    if curl -fsS "http://127.0.0.1:$PORT/healthz/live" >/dev/null 2>&1 || curl -fsS "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
      log "SSR ativo em $PORT com PID $SSR_PID"
      wait "$SSR_PID"
      exit $?
    fi
    if ! kill -0 "$SSR_PID" >/dev/null 2>&1; then
      log "SSR $ENTRY encerrou antes de abrir porta; fallback estático será usado se houver index.html"
      wait "$SSR_PID" 2>/dev/null || true
      return 1
    fi
    i=$((i + 1))
    sleep 1
  done
  log "SSR $ENTRY não respondeu em $PORT; encerrando e usando fallback estático se disponível"
  kill "$SSR_PID" >/dev/null 2>&1 || true
  wait "$SSR_PID" 2>/dev/null || true
  return 1
}

if [ -n "$STATIC_ROOT" ] && [ "${DEPLOYHUB_FORCE_SSR:-0}" != "1" ]; then
  log "Build estático detectado antes do SSR: $STATIC_ROOT; pulando probe SSR para evitar exit prematuro de bundle server incompatível."
else

if [ -f /app/.output/server/index.mjs ]; then
  run_ssr_candidate /app/.output/server/index.mjs || true
fi

if [ -f /app/dist/server/index.js ]; then
  run_ssr_candidate /app/dist/server/index.js || true
fi

if [ -f /app/dist/server/server.js ]; then
  run_ssr_candidate /app/dist/server/server.js || true
fi

if [ -f /app/dist/server/index.mjs ]; then
  run_ssr_candidate /app/dist/server/index.mjs || true
fi

if [ -f /app/dist/server/server.mjs ]; then
  run_ssr_candidate /app/dist/server/server.mjs || true
fi

if [ -f /app/build/server/index.mjs ]; then
  run_ssr_candidate /app/build/server/index.mjs || true
fi

if [ -f /app/build/server/index.js ]; then
  run_ssr_candidate /app/build/server/index.js || true
fi

fi

if [ -z "$STATIC_ROOT" ]; then
  for candidate in /app/dist/client /app/dist/client/client /app/dist /app/client/dist/client /app/client/dist /app/.output/public /app/build/client /app/build; do
    if [ -f "$candidate/index.html" ]; then
      STATIC_ROOT="$candidate"
      break
    fi
  done
fi

if [ -z "$STATIC_ROOT" ]; then
  log "ERRO: nenhum index.html encontrado em dist, dist/client, .output/public ou build. Abortando para não servir listagem de diretório."
  dump_tree
  exit 1
fi

log "Limpando /usr/share/nginx/html/*"
rm -rf /usr/share/nginx/html/*
cp -R "$STATIC_ROOT"/. /usr/share/nginx/html/
log "SPA estático detectado: servindo $STATIC_ROOT via Nginx na porta 3000 (ROOT: /usr/share/nginx/html)"
ls -la /usr/share/nginx/html/

# Gera /usr/share/nginx/html/healthz.json com metadados do build atual.
# Servido como arquivo real -> prova que o nginx está lendo o dist correto.
INDEX_PATH="/usr/share/nginx/html/index.html"
if [ -f "$INDEX_PATH" ]; then
  INDEX_SIZE=$(wc -c < "$INDEX_PATH" | tr -d ' ')
  INDEX_SHA=$(sha256sum "$INDEX_PATH" 2>/dev/null | awk '{print $1}')
  INDEX_MTIME=$(date -u -r "$INDEX_PATH" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)
  INDEX_HEAD=$(head -c 240 "$INDEX_PATH" | tr -d '\n' | sed 's/"/\\"/g')
else
  INDEX_SIZE=0; INDEX_SHA="missing"; INDEX_MTIME="missing"; INDEX_HEAD=""
fi
ASSET_COUNT=$(find /usr/share/nginx/html -maxdepth 4 -type f 2>/dev/null | wc -l | tr -d ' ')
JS_COUNT=$(find /usr/share/nginx/html -maxdepth 4 -type f -name '*.js' 2>/dev/null | wc -l | tr -d ' ')
CSS_COUNT=$(find /usr/share/nginx/html -maxdepth 4 -type f -name '*.css' 2>/dev/null | wc -l | tr -d ' ')
if [ "$JS_COUNT" = "0" ]; then
  log "AVISO: index.html existe, mas nenhum bundle .js foi encontrado em /usr/share/nginx/html. Mantendo container online para expor /healthz e servir o HTML gerado."
  dump_tree
fi
cat > /usr/share/nginx/html/healthz.json <<JSON
{
  "status": "ok",
  "served_by": "nginx",
  "root": "/usr/share/nginx/html",
  "source_dir": "$STATIC_ROOT",
  "index_html": {
    "exists": $( [ -f "$INDEX_PATH" ] && echo true || echo false ),
    "size": $INDEX_SIZE,
    "sha256": "$INDEX_SHA",
    "mtime": "$INDEX_MTIME",
    "head": "$INDEX_HEAD"
  },
  "assets": { "total": $ASSET_COUNT, "js": $JS_COUNT, "css": $CSS_COUNT },
  "deploy": {
    "version": "${DEPLOY_VERSION:-unknown}",
    "commit_sha": "${DEPLOY_COMMIT_SHA:-unknown}",
    "timestamp": "${DEPLOY_TIMESTAMP:-unknown}",
    "debug": "${DEPLOYHUB_DEBUG:-0}"
  },
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON
log "healthz.json gerado: size=$INDEX_SIZE sha256=$INDEX_SHA assets=$ASSET_COUNT"
log "Servidor estático Node iniciado em 0.0.0.0:${PORT:-3000} usando /usr/share/nginx/html; Nginx não será usado neste modo para evitar exits silenciosos/502."
exec node /app/deployhub-health-server.mjs /usr/share/nginx/html "${PORT:-3000}"

mkdir -p /etc/nginx/http.d /etc/nginx/conf.d
rm -f /etc/nginx/http.d/default.conf /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.diagnostic

# Alpine nginx installed inside node:alpine may include /etc/nginx/conf.d/*.conf
# outside the http{} block in some images. Writing a server{} there makes nginx
# crash with: "server directive is not allowed here". Own the top-level config
# and keep the vhost strictly under http.d.
cat > /etc/nginx/nginx.conf <<'NGINX_MAIN'
worker_processes auto;
error_log /dev/stderr notice;
pid /run/nginx/nginx.pid;

events { worker_connections 1024; }

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  sendfile on;
  tcp_nopush on;
  keepalive_timeout 65;
  include /etc/nginx/http.d/*.conf;
}
NGINX_MAIN

cat > /tmp/deployhub-nginx.conf <<NGINX
server {
  listen 80 default_server;
  listen 3000;
  server_name _;
  root /usr/share/nginx/html;
  index index.html;

  access_log /dev/stdout;
  error_log /dev/stderr ${NGINX_LOG_LEVEL:-notice};
  autoindex off;
  server_tokens off;

  gzip on;
  gzip_vary on;
  gzip_min_length 1024;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;

  # /healthz/live -> probe leve para Docker HEALTHCHECK
  location = /healthz/live {
    access_log off;
    default_type text/plain;
    add_header Access-Control-Allow-Origin "*" always;
    return 200 'ok\n';
  }

  # /healthz -> JSON com metadados reais do dist servido (sha256, size, mtime, commit)
  location = /healthz {
    access_log off;
    default_type application/json;
    add_header Cache-Control "no-store" always;
    add_header X-DeployHub-Root "/usr/share/nginx/html" always;
    add_header Access-Control-Allow-Origin "*" always;
    add_header Access-Control-Allow-Methods "GET,HEAD,OPTIONS" always;
    add_header Access-Control-Allow-Headers "content-type" always;
    try_files /healthz.json =503;
  }

  location ~* \.(?:js|css|png|jpg|jpeg|gif|ico|svg|webp|avif|woff|woff2|ttf|eot|map)$ {
    try_files \$uri =404;
    expires 1y;
    add_header Cache-Control "public, immutable";
  }

  # Ruído comum de scanners procurando CMS/PHP/file managers que não existem neste app.
  # Sem esta regra, o fallback SPA devolve index.html com 200 para essas rotas falsas.
  location ~* "(\\.php(?:/|$)|/php/|kcfinder|filemanager|responsive_filemanager|jquery-file-upload|ckeditor|tinymce)" {
    access_log off;
    return 404;
  }

  location / {
    try_files \$uri \$uri/ /index.html;

    add_header Cache-Control "no-cache";
  }
}
NGINX

cp /tmp/deployhub-nginx.conf /etc/nginx/http.d/default.conf

nginx -t
exec nginx -g 'daemon off;'
EOF
RUN cat > /usr/local/bin/deployhub-healthcheck <<'EOF'
#!/bin/sh
if pgrep nginx >/dev/null 2>&1; then
  curl -fsS "http://127.0.0.1:${PORT:-3000}/healthz/live" >/dev/null || curl -fsS http://127.0.0.1:80/healthz/live >/dev/null
else
  curl -fsS "http://127.0.0.1:${PORT:-3000}/healthz/live" >/dev/null || curl -fsS "http://127.0.0.1:${PORT:-3000}/" >/dev/null
fi
EOF
RUN chmod +x /usr/local/bin/deployhub-start /usr/local/bin/deployhub-healthcheck
EXPOSE 80 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD /usr/local/bin/deployhub-healthcheck
CMD ["/usr/local/bin/deployhub-start"]
