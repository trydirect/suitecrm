#!/bin/sh

set -e

chown www-data:www-data -R /app


cat > /app/suitecrm/config_override.php <<EOF
<?php

\$sugar_config['http_referer']['list'][] = '${VIRTUAL_HOST}';
EOF

cat >> /usr/local/etc/php-fpm.conf <<EOF
php_admin_value[upload_max_filesize] = 16M
php_admin_value[date.timezone] = "UTC"
EOF

cat > /root/cron.conf <<EOF
*    *    *    *    *     cd ${SUITE_APP_DIR}; php -f cron.php > /dev/null 2>&1 
EOF

crontab /root/cron.conf;
/usr/sbin/cron

cat > /etc/supervisor/conf.d/php5-fpm.conf <<EOF
[program:php5-fpm]
command = php-fpm
user = root
autostart = true
EOF

cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
command = nginx -g 'daemon off;'
user = root
autostart = true
EOF

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf