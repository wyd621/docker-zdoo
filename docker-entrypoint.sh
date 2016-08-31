#!/usr/bin/env bash

# 然之持久化操作
mkdir -p /data/session

persist_dirs="www/data config tmp"
dest_dir=/data/ranzhi
source_dir=/app/zdoo/ranzhi
mkdir -p ${dest_dir}
# 在持久化存储中创建需要的目录
for d in ${persist_dirs} ; do
    if [ -d ${dest_dir}/${d} ] ; then
        rm -rf ${source_dir}/${d}
    else
        mkdir -p ${dest_dir}/${d}
        cp -r ${source_dir}/${d}/* ${dest_dir}/${d}
        rm -rf ${source_dir}/${d}
    fi
    pdir=$(dirname ${source_dir}/${d})
    ln -s ${dest_dir}/${d} ${pdir}
done

echo "ranzhi success"

# 禅道安装持久化目录
persist_dirs="www/data config tmp module"
dest_dir=/data/zentaopms
source_dir=/app/zdoo/zentao
mkdir -p ${dest_dir}
# 在持久化存储中创建需要的目录
for d in ${persist_dirs} ; do
    if [ -d ${dest_dir}/${d} ] ; then
        rm -rf ${source_dir}/${d}
    else
        mkdir -p ${dest_dir}/${d}
        cp -r ${source_dir}/${d}/* ${dest_dir}/${d}
        rm -rf ${source_dir}/${d}
    fi
    pdir=$(dirname ${source_dir}/${d})
    ln -s ${dest_dir}/${d} ${pdir}
done

echo "zentao success"

# install.php和upgrade.php
user_config="${source_dir}/config/my.php"
install_file="${source_dir}/www/install.php"
upgrade_file="${source_dir}/www/upgrade.php"
if [ -f ${user_config} ]; then
    echo "now check zentao pms need delete install and upgrade"
    [ -f ${install_file} ] && rm -f ${install_file}
    [ -f ${upgrade_file} ] && rm -f ${upgrade_file}
fi

# 蝉知安装持久化目录
persist_dirs="system/config system/module system/tmp www/data"
dest_dir=/data/chanzhimall5.6
source_dir=/app/zdoo/chanzhi
mkdir -p ${dest_dir}
# 在持久化存储中创建需要的目录
for d in ${persist_dirs} ; do
    if [ -d ${dest_dir}/${d} ] ; then
        rm -rf ${source_dir}/${d}
    else
        mkdir -p ${dest_dir}/${d}
        cp -r  ${source_dir}/${d}/* ${dest_dir}/${d}
        rm -rf ${source_dir}/${d}
    fi
    pdir=$(dirname ${source_dir}/${d})
    ln -s ${dest_dir}/${d} ${pdir}
done

echo "chanzhi success"

# 设置权限
chmod -R www-data.www-data /data/

php5-fpm

nginx -g 'daemon off;'
