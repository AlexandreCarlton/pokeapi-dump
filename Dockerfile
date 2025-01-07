FROM nginx:1.25.3

# Modify this at runtime when running this in other set-ups, e.g. docker-compose
ENV ENDPOINT=http://localhost:80

COPY 90-substitute-endpoint.sh /docker-entrypoint.d
COPY 95-gzip-json.sh /docker-entrypoint.d
COPY default.conf /etc/nginx/conf.d
COPY dump /usr/share/nginx/html
