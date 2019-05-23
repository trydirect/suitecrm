FROM php:7.1-fpm

# SuiteCRM 7.11.2 MAX
ENV SUITE_GIT_BASE_URL https://github.com/salesagility/SuiteCRM/archive
ENV SUITE_GIT_ARCHIVE v7.11.2.zip
ENV SUITE_GIT_REPO ${SUITE_GIT_BASE_URL}/${SUITE_GIT_ARCHIVE}
ENV SUITE_APP_DIR /app

RUN groupadd -r -g 2000 trydirect; useradd -r -u 2000 -g 2000 -m -c "app account" -d /home/trydirect -s /bin/bash trydirect


RUN apt-get update && \
    apt-get install -y  libcurl4-gnutls-dev libpng-dev libssl-dev libc-client2007e-dev libkrb5-dev \
                        zlib1g-dev libicu-dev g++ \
                        unzip \
                        cron \
                        supervisor \
                        tar \
                        wget \
                        nginx \
                        nano \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install mysqli curl gd zip mbstring imap intl

RUN docker-php-ext-configure intl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${SUITE_APP_DIR} && wget ${SUITE_GIT_REPO} && unzip -qq ${SUITE_GIT_ARCHIVE} -d ${SUITE_APP_DIR} \
    && mv /app/SuiteCRM-7.11.2 /app/suitecrm

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer

WORKDIR /app/suitecrm

RUN composer install

COPY init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/* && rm /etc/nginx/sites-available/*
COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/nginx.conf /etc/nginx/nginx.conf

ADD ./scripts/letsencrypt-auto /opt/letsencrypt/letsencrypt-auto

RUN chmod +x /opt/letsencrypt/letsencrypt-auto; /opt/letsencrypt/letsencrypt-auto  --os-packages-only --install-only --non-interactive;
RUN chown -R trydirect. /app && \
    chown -R trydirect. /usr/local/etc/php-fpm.conf && \
    chown -R trydirect. /etc/supervisor && \
    chown -R trydirect. /var/log/

RUN echo "*    *    *    *    *     cd /app/suitecrm; php -f cron.php > /dev/null 2>&1" > /root/cron.conf && \
    crontab /root/cron.conf && \
    chown -R trydirect. /root/cron.conf && \
    chmod +s /usr/sbin/cron

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/init.sh"]
