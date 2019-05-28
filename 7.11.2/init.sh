#!/bin/sh

set -e

#chown suitecrm.suitecrm -R /app/suitecrm

cat > /app/suitecrm/config_override.php <<EOF
<?php

\$sugar_config['http_referer']['list'][] = '${VIRTUAL_HOST}';
EOF

chown suitecrm. /app/suitecrm/config_override.php

cat >> /usr/local/etc/php-fpm.conf <<EOF
user = suitecrm
group = suitecrm
php_admin_value[upload_max_filesize] = 16M
php_admin_value[date.timezone] = "UTC"
EOF

cat > /root/cron.conf <<EOF
*    *    *    *    *     cd ${SUITE_APP_DIR}; php -f cron.php > /dev/null 2>&1 
EOF

crontab /root/cron.conf;
/usr/sbin/cron

cat > /etc/supervisor/conf.d/php7-fpm.conf <<EOF
[program:php7-fpm]
command = php-fpm
autostart = true
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
EOF

cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
command = nginx -g 'daemon off;'
autostart = true
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
EOF

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf