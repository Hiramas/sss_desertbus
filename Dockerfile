FROM php:8.0-fpm-alpine3.14 AS base

RUN apk update && apk upgrade
RUN apk add --no-cache sqlite~=3.35.5-r0 php8-mbstring php8-sqlite3 php8-zip zip unzip
RUN apk add --no-cache git

RUN mkdir /tmp/db
RUN mkdir /tmp/logs
RUN mkdir /var/www/html/sss

RUN git clone --depth 1 --branch desertbus https://github.com/DesertBot/superseriousstats.git /tmp/sss
RUN git clone --depth 1 --branch master https://github.com/DesertBot/sss_desertbus.git /tmp/sss-config

RUN cp /tmp/sss-config/desertbus.conf /tmp/sss/sss.conf

CMD php /tmp/sss/sss.php -i /tmp/logs && \
    php /tmp/sss/sss.php -m /tmp/nick_aliases.txt && \
    php /tmp/sss/sss.php -o /var/www/html/sss/index.html
