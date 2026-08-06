# DEPLOYHUB_NITRO_NODESERVER_V4
# Dockerfile mínimo para Vite + Nitro preset "node-server".
# O bundle .output/server/index.mjs inicia o HTTP por si só (listen interno).
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
ENV NPM_CONFIG_PRODUCTION=false
# Usa o lockfile quando existir (instalação determinística). Sem lockfile o npm
# resolve versões novas de @tanstack/* de forma independente e o build SSR quebra
# com MISSING_EXPORT (ex.: "waitForRequest is not exported by @tanstack/router-core").
RUN if [ -f package-lock.json ]; then npm ci --legacy-peer-deps --include=dev || npm install --legacy-peer-deps --include=dev; else npm install --legacy-peer-deps --include=dev; fi
# Alinha TODO o ecossistema @tanstack com as versões declaradas por
# @tanstack/react-start / @tanstack/react-router. Sem isso o npm pode instalar um
# router-core mais antigo que o esperado pelo bundle SSR, gerando MISSING_EXPORT
# (waitForRequest, bindSsrResponseToRequest, disposeSsrResponseDetached...).
RUN node -e "const fs=require('fs');const roots=['react-start','start-plugin-core','react-router','router-core'];const out=new Set();for(const r of roots){let pkg;try{pkg=require('/app/node_modules/@tanstack/'+r+'/package.json')}catch(e){continue}for(const [k,v] of Object.entries(pkg.dependencies||{})){if(k.startsWith('@tanstack/')&&/^[\^~>=0-9]/.test(v))out.add(k+'@'+v)}}fs.writeFileSync('/tmp/tanstack-pins.txt',[...out].join(' '))" \
 && PINS=$(cat /tmp/tanstack-pins.txt) && if [ -n "$PINS" ]; then echo "[deployhub] alinhando @tanstack: $PINS" && npm install --no-save --legacy-peer-deps $PINS || true; fi
# Verificação final: o bundle SSR do TanStack Start importa símbolos novos de
# @tanstack/router-core (waitForRequest, bindSsrResponseToRequest, ...). Se a
# versão instalada não os exporta, sobe router-core/react-router para a versão
# mais nova encontrada no node_modules (ou latest) antes do build.
RUN cat > /tmp/deployhub-align.cjs <<'EOF'
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const NEED = ['waitForRequest', 'bindSsrResponseToRequest', 'disposeSsrResponseDetached', '_getRenderedMatches'];
const base = '/app/node_modules/@tanstack/router-core';
function readAll(dir) {
  let out = '';
  const stack = [dir];
  while (stack.length) {
    const cur = stack.pop();
    let entries = [];
    try { entries = fs.readdirSync(cur, { withFileTypes: true }); } catch (e) { continue; }
    for (const e of entries) {
      const p = path.join(cur, e.name);
      if (e.isDirectory()) stack.push(p);
      else if (e.name.endsWith('.js') || e.name.endsWith('.mjs') || e.name.endsWith('.d.ts')) {
        try { out += fs.readFileSync(p, 'utf8'); } catch (e2) {}
      }
    }
  }
  return out;
}
if (!fs.existsSync(base)) { console.log('[deployhub] router-core ausente; nada a alinhar'); process.exit(0); }
const src = readAll(path.join(base, 'dist'));
const missing = NEED.filter((s) => src.indexOf(s) === -1);
if (missing.length === 0) { console.log('[deployhub] router-core OK'); process.exit(0); }
console.log('[deployhub] router-core sem exports ' + missing.join(', ') + ' — atualizando @tanstack');
const pkgs = ['@tanstack/router-core@latest', '@tanstack/react-router@latest', '@tanstack/history@latest'];
try {
  cp.execSync('npm install --no-save --legacy-peer-deps ' + pkgs.join(' '), { stdio: 'inherit', cwd: '/app' });
} catch (e) {
  console.log('[deployhub] falha ao atualizar @tanstack: ' + e.message);
}
EOF
RUN node /tmp/deployhub-align.cjs || true
COPY . .
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
ENV NODE_ENV=production
# Força o build do Nitro/TanStack Start para Node server dentro do Docker.
# Importante: buildArgs do Dokploy nem sempre chegam como ENV no estágio build;
# sem isso o preset padrão pode voltar para cloudflare-module, gerando um
# .output/server/index.mjs que exporta handler e encerra com exit 0 quando
# executado via node, causando loop de container parado / Bad Gateway.
ENV NITRO_PRESET=node-server
RUN if [ -z "$VITE_SUPABASE_PUBLISHABLE_KEY" ]; then export VITE_SUPABASE_PUBLISHABLE_KEY="$VITE_SUPABASE_ANON_KEY"; fi && NITRO_PRESET=node-server npm run build
RUN test -f /app/.output/server/index.mjs || (echo "[deployhub] Nitro node-server bundle ausente em .output/server/index.mjs" && ls -la /app/.output/server || true && exit 1)

FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000
RUN apk add --no-cache curl ca-certificates
COPY --from=build /app/.output ./.output
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=5 CMD curl -fsS http://localhost:3000/healthz || curl -fsS http://localhost:3000/ || exit 1
CMD ["node", ".output/server/index.mjs"]
