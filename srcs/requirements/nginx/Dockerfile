FROM debian:bullseye

# Install required packages: nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
 && apt-get clean
# apt clean is used to remove cached files to reduce image size
# Copy custom nginx config
COPY ./tools/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Company/OU=Org/CN=localhost"

# Expose HTTPS port
EXPOSE 443

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
