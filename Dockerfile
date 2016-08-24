FROM php:5.6-fpm

RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

RUN echo "session.save_path=/data/session" > /usr/local/etc/php/conf.d/session.ini && \
    mkdir -p /data/session
    
RUN apt-get update && apt-get install -y \
        php5-mcrypt \
        libmcrypt4 \
        libmcrypt-dev \
        libpng-dev \
        vim \
        unzip \
        net-tools \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install \
        mysql \
        mysqli \
        sockets \
        pdo \
        pdo_mysql \
        zip \
        mbstring \
        mcrypt \
        gd 
        
RUN mkdir -p /app/

COPY docker-entrypoint.sh /app
COPY config/nginx.conf /etc/nginx/nginx.conf

#RUN curl http://lang.goodrain.me/tmp/zdoo.zip -o /app/zdoo.zip 

ADD zdoo.zip /app

RUN cd /app && unzip zdoo.zip && rm zdoo.zip

RUN chown www-data:www-data /app/zdoo/. -R

RUN mkdir -p /app/install && \
    cd /app/install && \

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
    
VOLUME /data

ENTRYPOINT ["/app/docker-entrypoint.sh"]