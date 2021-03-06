FROM php:5.6-fpm

# SuiteCRM 7.7.8 MAX
ENV SUITE_GIT_BASE_URL https://github.com/optimum-web/SuiteCRM/archive
ENV SUITE_GIT_ARCHIVE optimum-patches.zip
ENV SUITE_GIT_REPO ${SUITE_GIT_BASE_URL}/${SUITE_GIT_ARCHIVE}
ENV SUITE_APP_DIR /app

RUN groupadd -r -g 2000 trydirect; useradd -r -u 2000 -g 2000 -m -c "app account" -d /home/trydirect -s /bin/bash trydirect

RUN apt-get update && \
    apt-get install -y  libcurl4-gnutls-dev libpng-dev libssl-dev libc-client2007e-dev libkrb5-dev \
                        unzip \
                        cron \
                        supervisor \
                        tar \
                        wget \
                        nginx \
                        nano \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install mysql curl gd zip mbstring imap \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${SUITE_APP_DIR} && wget ${SUITE_GIT_REPO} && unzip -qq ${SUITE_GIT_ARCHIVE} -d ${SUITE_APP_DIR}
RUN mv /app/SuiteCRM-optimum-patches /app/suitecrm

COPY init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh

COPY config/suitecrm.conf /etc/nginx/conf.d/suitecrm.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN rm /etc/nginx/sites-enabled/* && rm /etc/nginx/sites-available/*

ADD ./scripts/letsencrypt-auto /opt/letsencrypt/letsencrypt-auto

RUN chmod +x /opt/letsencrypt/letsencrypt-auto; /opt/letsencrypt/letsencrypt-auto  --os-packages-only --install-only --non-interactive;


EXPOSE 80

ENTRYPOINT ["/usr/local/bin/init.sh"]
