FROM php:5.6-fpm

# 时区设置
RUN echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    echo "session.save_path=/data/session" > /usr/local/etc/php/conf.d/session.ini && \
    docker-php-ext-install mysql \
        mysqli \
        sockets \
        pdo \
        pdo_mysql && \
    apt-get update && \
    apt-get -y install nginx unzip && \
    mkdir -p /app/zdoo

COPY docker-entrypoint.sh /app
COPY config/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /app/install && \
    cd /app/install && \
    curl -fSL "http://dl.cnezsoft.com/chanzhi/mall/1.0/php5.6/chanzhimall.zip?2016628" \
         -o chanzhimall.zip && \
    unzip -qon chanzhimall.zip -d /app/zdoo && \

    curl -fSL "http://dl.cnezsoft.com/ranzhi/pro.1.0/ranzhi.Pro1.0.stable.zip?v=160420" \
             -o ranzhi.zip && \
    unzip -qon ranzhi.zip -d /app/zdoo && \

    curl -fSL "http://dl.cnezsoft.com/zentao/pro5.3/ZenTaoPMS.Pro5.3.stable.zip" \
             -o zentaopms.zip && \
    unzip -qon zentaopms.zip -d /app/zdoo && \

    curl -fSL "http://downloads.zend.com/guard/7.0.0/zend-loader-php5.6-linux-x86_64.tar.gz" \
        -o zend-loader-php5.6-linux-x86_64.tar.gz && \
    tar zxf zend-loader-php5.6-linux-x86_64.tar.gz && \
    cp zend-loader-php5.6-linux-x86_64/*.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/ && \

    curl -fSL "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" \
        -o ioncube_loaders_lin_x86-64.tar.gz && \
    tar zxf ioncube_loaders_lin_x86-64.tar.gz && \
    cp ioncube/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/ && \

    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/ioncube_loader_lin_5.6.so" > /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/ZendGuardLoader.so" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/opcache.so" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    rm -rf /app/install


VOLUME /data/session
VOLUME /mnt/data

EXPOSE 5000

ENTRYPOINT ["/app/docker-entrypoint.sh"]