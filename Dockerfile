# DEPLOYHUB_NGINX_SPA_V16
FROM node:22-alpine AS build
WORKDIR /app
COPY . .
RUN if [ -f package.json ]; then npm install --legacy-peer-deps; else echo "no package.json"; exit 1; fi
RUN npm run build

FROM node:22-alpine AS runtime
WORKDIR /app
RUN apk add --no-cache nginx curl ca-certificates &&   mkdir -p /run/nginx /var/log/nginx /usr/share/nginx/html /etc/nginx/http.d /etc/nginx/conf.d
COPY --from=build /app/dist ./dist
# If build generated dist/client, use it. Otherwise use dist.
RUN if [ -d dist/client ]; then cp -r dist/client/. /usr/share/nginx/html/; else cp -r dist/. /usr/share/nginx/html/; fi

# Robust Nginx config for port 3000
RUN printf 'server { \n\
  listen 3000 default_server; \n\
  server_name _; \n\
  root /usr/share/nginx/html; \n\
  index index.html; \n\
  location / { \n\
    try_files $uri $uri/ /index.html; \n\
  } \n\
  location = /healthz/live { \n\
    access_log off; \n\
    return 200 "ok\\n"; \n\
  } \n\
}' > /etc/nginx/http.d/default.conf

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
