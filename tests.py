#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import docker
import requests

client = docker.from_env()

time.sleep(10)

for c in client.containers.list():
    print("{}: {}" .format(c.name, c.status))
    if 'running' not in c.status:
        print(c.logs())

# NGINX
nginx = client.containers.get('suitecrm')
nginx_cfg = nginx.exec_run("/usr/sbin/nginx -T")
assert nginx.status == 'running'
# print(nginx_cfg.output.decode())
assert 'server_name _;' in nginx_cfg.output.decode()
assert "error_log /proc/self/fd/2" in nginx_cfg.output.decode()
assert "location = /.well-known/acme-challenge/" in nginx_cfg.output.decode()
assert 'HTTP/1.1" 500' not in nginx.logs()

# test restart
nginx.restart()
time.sleep(3)
assert nginx.status == 'running'

# PHP
php = client.containers.get('suitecrm')
assert php.status == 'running'
php_conf = php.exec_run("php-fpm -t")
# print(php_conf.output.decode())
php_proc = php.exec_run("sh -c 'ps aux |grep php-fpm'")
print(php_proc.output.decode())
assert 'configuration file /usr/local/etc/php-fpm.conf test is successful' in php_conf.output.decode()
assert 'php-fpm: master process (/usr/local/etc/php-fpm.conf)' in php_proc.output.decode()
assert 'php-fpm: pool www' in php_proc.output.decode()
assert 'suitecrm' in php_proc.output.decode()

mysql = client.containers.get('db')
assert mysql.status == 'running'
mycnf = mysql.exec_run("/usr/sbin/mysqld --verbose  --help")
# print(mycnf.output.decode())
mysql_log = mysql.logs()
print(mysql_log.decode())
assert "mysqld: ready for connections" in mysql_log.decode()
assert '-MariaDB' in mysql_log.decode()

response = requests.get("http://localhost")
assert "SuiteCRM Setup Wizard:  Welcome to the SuiteCRM  7.11.2 Setup Wizard, License Acceptance<" in response.text
assert response.status_code == 200
