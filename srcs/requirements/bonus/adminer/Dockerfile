FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysqli \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/^listen = .*/listen = 9001/" /etc/php/8.2/fpm/pool.d/*.conf

WORKDIR /var/www/html

RUN curl -Lo index.php https://www.adminer.org/static/download/5.5.1/adminer-5.5.1.php

COPY tools/init_adminer.sh /usr/local/bin/init_adminer.sh
RUN chmod +x /usr/local/bin/init_adminer.sh

EXPOSE 9001

ENTRYPOINT ["/usr/local/bin/init_adminer.sh"]
