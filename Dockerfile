FROM php:5.6-apache

ENV ZDOO_FILE="zdoo_201701243.tar.gz"
# 时区设置
RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

RUN rm -rf  /usr/local/bin/php /usr/local/etc/php /usr/local/lib/php /usr/local/php
RUN apt-get update && apt-get install -y \
        git \
        subversion \
        libmcrypt4 \
        libmcrypt-dev \
        libpng-dev \
        vim \
        unzip \
        curl \
        wget \
        net-tools \
        php5 \
        php5-curl \
        php5-gd \
        php5-mysql \
        php5-mcrypt \
    --no-install-recommends && rm -r /var/lib/apt/lists/*
 
RUN mkdir -p /app/

COPY docker-entrypoint.sh /app

RUN curl http://lang.goodrain.me/tmp/${ZDOO_FILE} -o /app/zdoo.tar.gz
RUN cd /app && tar zxfp zdoo.tar.gz && rm zdoo.tar.gz

COPY config/zdoo.apache.conf /etc/apache2/sites-available/zdoo.conf
RUN rm /etc/apache2/sites-enabled/* && \
    ln -s /etc/apache2/sites-available/zdoo.conf /etc/apache2/sites-enabled/zdoo.conf && \
    a2enmod rewrite

RUN chown www-data:www-data /app/zdoo/. -R

 RUN mkdir -p /app/install && \
     cd /app/install && \

     curl -fsSL "http://lang.goodrain.me/tmp/zend-loader-php5.6-linux-x86_64.tar.gz" \
         -o zend-loader-php5.6-linux-x86_64.tar.gz && \
     tar zxf zend-loader-php5.6-linux-x86_64.tar.gz && \
     cp zend-loader-php5.6-linux-x86_64/*.so /usr/lib/php5/20131226/ && \

     curl -fsSL "http://lang.goodrain.me/tmp/ioncube_loaders_lin_x86-64.tar.gz" \
         -o ioncube_loaders_lin_x86-64.tar.gz && \
     tar zxf ioncube_loaders_lin_x86-64.tar.gz && \
     cp ioncube/ioncube_loader_lin_5.6.so /usr/lib/php5/20131226/ && \

     echo "zend_extension=/usr/lib/php5/20131226/ioncube_loader_lin_5.6.so" > /etc/php5/mods-available/ioncube_loader_lin.ini && \
     echo "zend_extension=/usr/lib/php5/20131226/ZendGuardLoader.so" > /etc/php5/mods-available/zendGuardLoader.ini && \

     ln -s /etc/php5/mods-available/zendGuardLoader.ini /etc/php5/apache2/conf.d/20-zendGuardLoader.ini && \
     ln -s /etc/php5/mods-available/zendGuardLoader.ini /etc/php5/cli/conf.d/20-zendGuardLoader.ini && \
     ln -s /etc/php5/mods-available/ioncube_loader_lin.ini /etc/php5/apache2/conf.d/01-ioncube_loader_lin.ini && \
     ln -s /etc/php5/mods-available/ioncube_loader_lin.ini /etc/php5/cli/conf.d/01-ioncube_loader_lin.ini && \

     rm -rf /app/install

WORKDIR /app/zdoo

VOLUME /data

ENTRYPOINT ["/app/docker-entrypoint.sh"]
