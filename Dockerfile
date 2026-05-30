# DEPLOYHUB_TANSTACK_STATIC_V2
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
RUN if [ -z "$VITE_SUPABASE_PUBLISHABLE_KEY" ]; then export VITE_SUPABASE_PUBLISHABLE_KEY="$VITE_SUPABASE_ANON_KEY"; fi && npm run build
RUN test -f dist/client/index.html && echo "Static client build OK"

FROM nginx:stable-alpine AS runtime
RUN apk add --no-cache curl
ENV PORT=3000
RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/http.d/default.conf && \
    printf '%s
' \
'events { worker_connections 1024; }' \
'http {' \
'  include /etc/nginx/mime.types;' \
'  default_type application/octet-stream;' \
'  sendfile on;' \
'  server {' \
'    listen 3000 default_server;' \
'    server_name _;' \
'    root /usr/share/nginx/html;' \
'    index index.html;' \
'    location = /healthz/live { access_log off; default_type text/plain; return 200 "ok\n"; }' \
'    location = /healthz { access_log off; default_type application/json; return 200 "{\"status\":\"ok\"}\n"; }' \
'    location /assets/ { try_files $uri =404; access_log off; add_header Cache-Control "public, max-age=31536000, immutable"; }' \
'    location = /favicon.ico { try_files $uri =404; access_log off; }' \
'    location / { try_files $uri $uri/ /index.html; }' \
'  }' \
'}' > /etc/nginx/nginx.conf
COPY --from=build /app/dist/client/ /usr/share/nginx/html/
RUN test -f /usr/share/nginx/html/index.html && chmod -R a+rX /usr/share/nginx/html
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD curl -fsS http://localhost:3000/healthz/live || exit 1
CMD ["nginx", "-g", "daemon off;"]
