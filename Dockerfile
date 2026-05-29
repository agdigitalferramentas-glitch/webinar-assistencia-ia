# DEPLOYHUB_NGINX_SPA_V14
# Dockerfile robusto para Dokploy: Vite/React SPA via Nginx + fallback SSR TanStack/Node, inclusive apps dentro de /client.
FROM node:22-alpine AS build
WORKDIR /app
COPY . .
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
RUN if [ -f package.json ]; then npm install --legacy-peer-deps; elif [ -f client/package.json ]; then cd client && npm install --legacy-peer-deps; else echo "package.json não encontrado na raiz nem em /client"; exit 1; fi
RUN if [ -z "$VITE_SUPABASE_PUBLISHABLE_KEY" ]; then export VITE_SUPABASE_PUBLISHABLE_KEY="$VITE_SUPABASE_ANON_KEY"; fi && if [ -f package.json ]; then npm run build; elif [ -f client/package.json ]; then cd client && npm run build; fi
# Fallback SPA build: se gerou dist/server mas faltou index.html no client, força um vite build SPA puro
RUN set -eu;   ROOT=/app; [ -f /app/package.json ] || ROOT=/app/client;   cd "$ROOT";   if [ -d dist/server ] && [ ! -f dist/client/index.html ] && [ ! -f dist/index.html ]; then     echo "[deployhub:build] SSR build sem index.html — rodando vite build SPA de fallback em dist/client";     if [ -f node_modules/.bin/vite ]; then       ./node_modules/.bin/vite build --outDir dist/client --emptyOutDir=false ||       npx --yes vite build --outDir dist/client --emptyOutDir=false || true;     else       npx --yes vite build --outDir dist/client --emptyOutDir=false || true;     fi;   fi;   if [ ! -f dist/client/index.html ] && [ ! -f dist/index.html ]; then     if [ -f index.html ]; then       echo "[deployhub:build] último recurso: copiando index.html da raiz para dist/client";       mkdir -p dist/client; cp index.html dist/client/index.html;     elif [ -f client/index.html ]; then       echo "[deployhub:build] último recurso: copiando client/index.html para dist/client";       mkdir -p dist/client; cp client/index.html dist/client/index.html;     fi;   fi
RUN mkdir -p /app/dist /app/client/dist /app/.output /app/build &&   echo "[deployhub:build] build output candidates:" &&   for path in /app/dist /app/dist/client /app/client/dist /app/client/dist/client /app/.output/public /app/build /app/build/client; do     if [ -d "$path" ]; then echo "--- $path"; ls -la "$path"; fi;   done

FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache nginx curl ca-certificates &&   mkdir -p /run/nginx /var/log/nginx /usr/share/nginx/html /etc/nginx/http.d /etc/nginx/conf.d
COPY --from=build /app/dist ./dist
COPY --from=build /app/client/dist ./client/dist
COPY --from=build /app/.output ./.output
COPY --from=build /app/build ./build
COPY --from=build /app/deployhub-health-server.mjs ./deployhub-health-server.mjs
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

if [ -f /app/.output/server/index.mjs ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/.output/server/index.mjs na porta $PORT"
  exec node /app/.output/server/index.mjs
fi

if [ -f /app/dist/server/index.js ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/dist/server/index.js na porta $PORT"
  exec node /app/dist/server/index.js
fi

if [ -f /app/dist/server/server.js ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/dist/server/server.js na porta $PORT"
  exec node /app/dist/server/server.js
fi

if [ -f /app/dist/server/index.mjs ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/dist/server/index.mjs na porta $PORT"
  exec node /app/dist/server/index.mjs
fi

if [ -f /app/dist/server/server.mjs ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/dist/server/server.mjs na porta $PORT"
  exec node /app/dist/server/server.mjs
fi

if [ -f /app/build/server/index.mjs ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/build/server/index.mjs na porta $PORT"
  exec node /app/build/server/index.mjs
fi

if [ -f /app/build/server/index.js ]; then
  export HOST=0.0.0.0
  export PORT="${PORT:-3000}"
  log "SSR detectado: rodando /app/build/server/index.js na porta $PORT"
  exec node /app/build/server/index.js
fi

STATIC_ROOT=""
for candidate in /app/dist/client /app/dist /app/client/dist/client /app/client/dist /app/.output/public /app/build/client /app/build; do
  if [ -f "$candidate/index.html" ]; then
    STATIC_ROOT="$candidate"
    break
  fi
done

if [ -z "$STATIC_ROOT" ]; then
  log "ERRO: nenhum index.html encontrado em dist, dist/client, .output/public ou build. Abortando para não servir listagem de diretório."
  dump_tree
  exit 1
fi

log "Limpando /usr/share/nginx/html/*"
rm -rf /usr/share/nginx/html/*
cp -R "$STATIC_ROOT"/. /usr/share/nginx/html/
log "SPA estático detectado: servindo $STATIC_ROOT via Nginx na porta 80 (ROOT: /usr/share/nginx/html)"
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
  log "ERRO: index.html existe, mas nenhum bundle JavaScript foi encontrado em /usr/share/nginx/html. Build incompleto; abortando para não publicar página quebrada."
  dump_tree
  exit 1
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
