FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysqli \
    php-curl \
    php-gd \
    php-xml \
    php-mbstring \
    php-zip \
    mariadb-client \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN sed -i "s/^listen = .*/listen = 9000/" /etc/php/8.2/fpm/pool.d/*.conf

WORKDIR /var/www/html

COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init_wp.sh"]

