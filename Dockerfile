FROM ubuntu:trusty-20160819
MAINTAINER lichao <lic@goodrain.com>


ENV ZDOO_FILE="zdoo_0906.tar.gz"

RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

COPY sources.list /etc/apt/sources.list
RUN apt-get update && apt-get install -y software-properties-common git subversion

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
        php5-curl\
        php5-gd && \
     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN mkdir -p /app/

COPY docker-entrypoint.sh /app
COPY config/zdoo.conf /etc/nginx/sites-available/zdoo.conf
RUN ln -s /etc/nginx/sites-available/zdoo.conf /etc/nginx/sites-enabled/zdoo.conf && \
    rm /etc/nginx/sites-enabled/default

RUN curl http://lang.goodrain.me/tmp/${ZDOO_FILE} -o /app/zdoo.tar.gz


RUN cd /app && tar zxfp zdoo.tar.gz && rm zdoo.tar.gz

RUN chown www-data:www-data /app/zdoo -R

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

    ln -s /etc/php5/mods-available/zendGuardLoader.ini /etc/php5/fpm/conf.d/20-zendGuardLoader.ini && \

    ln -s /etc/php5/mods-available/ioncube_loader_lin.ini /etc/php5/fpm/conf.d/01-ioncube_loader_lin.ini && \

    rm -rf /app/install


WORKDIR /app/zdoo
VOLUME /data

ENTRYPOINT ["/app/docker-entrypoint.sh"]
