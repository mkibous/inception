FROM debian:bullseye

WORKDIR /var/www/html

# Install PHP-FPM and needed extensions
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-xml \
    php-mbstring \
    mariadb-client \
    curl \
    && apt-get clean

# Download and extract WordPress
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz --strip-components=1 -C /var/www/html && \
    rm wordpress.tar.gz
# WP-CLI (wordpress command line interface)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Startup script
COPY ./tools/startup.sh /startup.sh
RUN chmod +x /startup.sh

EXPOSE 9000

CMD ["/startup.sh"]
