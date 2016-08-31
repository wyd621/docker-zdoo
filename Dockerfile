FROM ubuntu:14.04
MAINTAINER lichao <lic@goodrain.com>

RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata


RUN apt-get update && apt-get install -y software-properties-common

ENV LANG="en_US.UTF8"

RUN echo -e "LANG=\"en_US.UTF-8\"\nLANGUAGE=\"en_US:en\"" > /etc/default/locale


RUN locale-gen en_US.UTF-8


RUN add-apt-repository -y ppa:ondrej/php5-5.6 && apt-get -y update && apt-get -y upgrade

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys E5267A6C && \
    echo 'deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main' > /etc/apt/sources.list.d/ondrej-php5-trusty.list && \
    apt-get install -y \
        nginx \
        php5-fpm \
        net-tools \
        vim \
        telnet \
        wget \
        zip \
        curl \
        php5-mysql \
        php5-mcrypt\
        php5-gd && \
     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN mkdir -p /app/

COPY docker-entrypoint.sh /app
COPY config/zdoo.conf /etc/nginx/sites-available/zdoo.conf
RUN ln -s /etc/nginx/sites-available/zdoo.conf /etc/nginx/sites-enabled/zdoo.conf && \
    rm /etc/nginx/sites-enabled/default

#RUN curl http://lang.goodrain.me/tmp/zdoo_0829.zip -o /app/zdoo.zip

ADD zdoo.zip /app

RUN cd /app && unzip zdoo.zip && rm zdoo.zip

RUN chown www-data:www-data /app/zdoo/. -R

RUN mkdir -p /app/install && \
    cd /app/install && \

    curl -fSL "http://downloads.zend.com/guard/7.0.0/zend-loader-php5.6-linux-x86_64.tar.gz" \
        -o zend-loader-php5.6-linux-x86_64.tar.gz && \
    tar zxf zend-loader-php5.6-linux-x86_64.tar.gz && \
    cp zend-loader-php5.6-linux-x86_64/*.so /usr/lib/php5/20131226/ && \

    curl -fSL "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" \
        -o ioncube_loaders_lin_x86-64.tar.gz && \
    tar zxf ioncube_loaders_lin_x86-64.tar.gz && \
    cp ioncube/ioncube_loader_lin_5.6.so /usr/lib/php5/20131226/ && \

    echo "zend_extension=/usr/lib/php5/20131226/ioncube_loader_lin_5.6.so" > /etc/php5/mods-available/ioncube_loader_lin.ini && \
    echo "zend_extension=/usr/lib/php5/20131226/ZendGuardLoader.so" > /etc/php5/mods-available/zendGuardLoader.ini && \

    ln -s /etc/php5/mods-available/zendGuardLoader.ini /etc/php5/fpm/conf.d/20-zendGuardLoader.ini && \

    ln -s /etc/php5/mods-available/ioncube_loader_lin.ini /etc/php5/fpm/conf.d/01-ioncube_loader_lin.ini && \

    rm -rf /app/install

COPY run.sh /app
RUN chmod +x /app/run.sh

WORKDIR /app/zdoo
VOLUME /data

#ENTRYPOINT ["/app/run.sh"]
ENTRYPOINT ["/app/docker-entrypoint.sh"]
