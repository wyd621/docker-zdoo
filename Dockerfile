FROM ubuntu:trusty-20160819
MAINTAINER lichao <lic@goodrain.com>

ENV ZDOO_FILE="zdoo_201701243.tar.gz"

RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

COPY sources.list /etc/apt/sources.list
RUN apt-get update && apt-get install -y software-properties-common git subversion

ENV LANG="en_US.UTF8"
RUN echo -e "LANG=\"en_US.UTF-8\"\nLANGUAGE=\"en_US:en\"" > /etc/default/locale
RUN locale-gen en_US.UTF-8

RUN sudo add-apt-repository ppa:ondrej/php && apt-get -y update && apt-get -y upgrade

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys E5267A6C
RUN echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu trusty main' > /etc/apt/sources.list.d/ondrej-php5-trusty.list
RUN echo 'deb-src http://ppa.launchpad.net/ondrej/php/ubuntu trusty main' >> /etc/apt/sources.list.d/ondrej-php5-trusty.list
RUN apt-get update

RUN apt-get install -y \
        apache2 \
        libapache2-mod-php5.6 \
        net-tools \
        vim \
        telnet \
        wget \
        zip \
        curl \
        php5.6 \
        php5.6-mysql \
        php5.6-mcrypt\
        php5.6-curl\
        php5.6-cli\
        php5.6-json\
        php5.6-mbstring\
        php5.6-gd && \
     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /app/

COPY docker-entrypoint.sh /app
COPY config/zdoo.apache.conf /etc/apache2/sites-available/zdoo.conf
RUN rm /etc/apache2/sites-enabled/* && \
    ln -s /etc/apache2/sites-available/zdoo.conf /etc/apache2/sites-enabled/zdoo.conf && \
    a2enmod rewrite

RUN curl http://lang.goodrain.me/tmp/${ZDOO_FILE} -o /app/zdoo.tar.gz


RUN cd /app && tar zxfp zdoo.tar.gz && rm zdoo.tar.gz

RUN chown www-data:www-data /app/zdoo -R

RUN mkdir -p /app/install && \
    cd /app/install && \

    curl -fsSL "http://lang.goodrain.me/tmp/zend-loader-php5.6-linux-x86_64.tar.gz" \
        -o zend-loader-php5.6-linux-x86_64.tar.gz && \
    tar zxf zend-loader-php5.6-linux-x86_64.tar.gz && \
    cp zend-loader-php5.6-linux-x86_64/*.so /usr/lib/php/20131226/ && \

    curl -fsSL "http://lang.goodrain.me/tmp/ioncube_loaders_lin_x86-64.tar.gz" \
        -o ioncube_loaders_lin_x86-64.tar.gz && \
    tar zxf ioncube_loaders_lin_x86-64.tar.gz && \
    cp ioncube/ioncube_loader_lin_5.6.so /usr/lib/php/20131226/ && \

    echo "zend_extension=/usr/lib/php/20131226/ioncube_loader_lin_5.6.so" > /etc/php/5.6/mods-available/ioncube_loader_lin.ini && \
    echo "zend_extension=/usr/lib/php/20131226/ZendGuardLoader.so" > /etc/php/5.6/mods-available/zendGuardLoader.ini && \

#    ln -s /etc/php/5.6/mods-available/zendGuardLoader.ini /etc/php/5.6/fpm/conf.d/20-zendGuardLoader.ini && \
#    ln -s /etc/php/5.6/mods-available/zendGuardLoader.ini /etc/php/5.6/cli/conf.d/20-zendGuardLoader.ini && \
#    ln -s /etc/php/5.6/mods-available/ioncube_loader_lin.ini /etc/php/5.6/fpm/conf.d/01-ioncube_loader_lin.ini && \
#    ln -s /etc/php/5.6/mods-available/ioncube_loader_lin.ini /etc/php/5.6/cli/conf.d/01-ioncube_loader_lin.ini && \

#    sed -i 's/^;pm\.max_requests.*$/pm\.max_requests = 200000/g' /etc/php/5.6/fpm/pool.d/www.conf && \

    rm -rf /app/install


WORKDIR /app/zdoo
VOLUME /data

ENTRYPOINT ["/app/docker-entrypoint.sh"]
