# DEPLOYHUB_TANSTACK_SSR_V1
FROM node:22-alpine AS build
WORKDIR /app
COPY . .
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
ENV NITRO_PRESET=node-server
RUN npm install --legacy-peer-deps
RUN if [ -z "$VITE_SUPABASE_PUBLISHABLE_KEY" ]; then export VITE_SUPABASE_PUBLISHABLE_KEY="$VITE_SUPABASE_ANON_KEY"; fi && NITRO_PRESET=node-server npm run build
RUN echo "=== build output ===" && ls -la .output 2>/dev/null || true && ls -la .output/server 2>/dev/null || true && ls -la dist 2>/dev/null || true

FROM node:22-alpine AS runtime
WORKDIR /app
RUN apk add --no-cache curl
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0
COPY --from=build /app/.output ./.output
COPY --from=build /app/dist ./dist
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD curl -fsS http://localhost:3000/ || exit 1
CMD sh -c 'if [ -f .output/server/index.mjs ]; then exec node .output/server/index.mjs; else echo "No .output/server/index.mjs"; ls -la .output 2>/dev/null; ls -la dist 2>/dev/null; exit 1; fi'
