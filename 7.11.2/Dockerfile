FROM php:7.1-fpm

LABEL maintainer="info@optimum-web.com"

# SuiteCRM 7.11.2 MAX
ENV SUITE_GIT_BASE_URL https://github.com/salesagility/SuiteCRM/archive
ENV SUITE_GIT_ARCHIVE v7.11.2.zip
ENV SUITE_GIT_REPO ${SUITE_GIT_BASE_URL}/${SUITE_GIT_ARCHIVE}
ENV SUITE_APP_DIR /app

RUN apt-get update && \
    apt-get install --no-install-recommends -y -qq libcurl4-gnutls-dev libpng-dev libssl-dev libc-client2007e-dev libkrb5-dev \
                        zlib1g-dev libicu-dev g++ unzip cron supervisor tar wget nginx procps git \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install mysqli curl gd zip mbstring imap intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -r -g 2000 suitecrm
RUN useradd -u 2000 -g 2000 -m -d /home/suitecrm -s /bin/bash suitecrm && adduser suitecrm sudo

ADD ./scripts/letsencrypt-auto /opt/letsencrypt/letsencrypt-auto
RUN chmod +x /opt/letsencrypt/letsencrypt-auto; /opt/letsencrypt/letsencrypt-auto  --os-packages-only --install-only --non-interactive;

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
RUN chown suitecrm. -R /app/suitecrm
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/init.sh"]
