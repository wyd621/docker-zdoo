#!/usr/bin/env bash

# link file
for d in "ranzhi zentao chanzhi"
do
# 应用目录有data 目录先删除
[ -d /app/zdoo/${d}/www/data ] && rm -rf /app/zdoo/${d}/www/data

# 将持久化目录软连接到应用目录中
[ -d /mnt/upload/$d ] && ln -s /app/zdoo/${d}/www/data

done

# 设置权限
chown -R www-data.www-data /data/

php5-fpm

nginx -g 'daemon off;'
