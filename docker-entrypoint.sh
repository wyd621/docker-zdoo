#!/usr/bin/env bash

[ $DEBUG ] && set -x

# link file
for d in ranzhi zentao chanzhi
do
  # 判断是否是第一次启动应用
  if [ -f /mnt/upload/${d}/.inited ];then
    mv /app/zdoo/${d}/www/data /app/zdoo/${d}/www/data.bak
  else
    [ -d /app/zdoo/${d}/www/data ] && \
    cp -rp /app/zdoo/${d}/www/data/* /mnt/upload/${d}/ && \
    rm -rf /app/zdoo/${d}/www/data
  fi

  # 将持久化目录软连接到应用目录中
  [ -d /mnt/upload/$d ] && ln -s /mnt/upload/$d /app/zdoo/${d}/www/data && touch /mnt/upload/${d}/.inited
done

# 设置权限
chown -R www-data.www-data /mnt/

/etc/init.d/php5.6-fpm start

nginx -g 'daemon off;'
