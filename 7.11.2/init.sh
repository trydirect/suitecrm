#!/bin/sh

set -e


cat > /app/suitecrm/config_override.php <<EOF
<?php

\$sugar_config['http_referer']['list'][] = '${VIRTUAL_HOST}';
EOF

cat >> /usr/local/etc/php-fpm.conf <<EOF
php_admin_value[upload_max_filesize] = 16M
php_admin_value[date.timezone] = "UTC"
EOF

/usr/sbin/cron

cat > /etc/supervisor/conf.d/php5-fpm.conf <<EOF
[program:php5-fpm]
command = php-fpm -F
user = root
autostart = true
EOF

cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
command = nginx -g 'daemon off;'
user = root
autostart = true
EOF

chmod +w /app/suitecrm/config_override.php

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
