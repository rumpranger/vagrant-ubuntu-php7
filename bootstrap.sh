#!/usr/bin/env bash

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

add-apt-repository ppa:ondrej/php
add-apt-repository ppa:webupd8team/java
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' > /etc/apt/sources.list.d/elasticsearch-2.x.list

apt-get update -y

apt-get install -y \
    make \
    build-essential \
    curl \
    wget \
    openssl \
    pkg-config \
    language-pack-en-base \
    git \
    vim \
    libtool \
    libmemcached-dev \
    libssl-dev \
    python-software-properties

## Create www dir
mkdir -p /var/www/html

## Install mysql 5.6
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install -y mysql-server-5.6
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sed -i 's/= 127.0.0.1/= 0.0.0.0/g' /etc/mysql/my.cnf

service mysql restart

## Install nginx
apt-get install -y nginx

## Add php modules
apt-get install -y \
    php7.0 \
    php7.0-cli \
    php7.0-common \
    php7.0-curl \
    php7.0-dev \
    php7.0-fpm \
    php7.0-gd \
    php7.0-imap \
    php7.0-intl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-zip \
    php-memcached \
    php-xdebug \
    php-amqp \
    php-apc

### Configure PHP
sed -i 's/^memory_limit = 128M/memory_limit = 256M/g' /etc/php/7.0/fpm/php.ini
sed -i 's/^;date.timezone =/date.timezone = America\/Montreal/g' /etc/php/7.0/fpm/php.ini
sed -i 's/^;date.timezone =/date.timezone = America\/Montreal/g' /etc/php/7.0/cli/php.ini

## Install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

## Install rabbit mq
apt-get install -y rabbitmq-server

## Install node
apt-get install -y \
    nodejs \
    npm

ln -s /usr/bin/nodejs /usr/local/bin/node

npm install uglify-js -g
npm install uglifycss -g

## Configure Nginx
rm /etc/nginx/sites-enabled/rabbitsreviews
mv /tmp/rabbitsreviews.conf /etc/nginx/sites-available/rabbitsreviews.conf
ln -s /etc/nginx/sites-available/rabbitsreviews.conf /etc/nginx/sites-enabled/rabbitsreviews.conf

service php7.0-fpm restart
service nginx restart

## Install Java
debconf-set-selections <<< 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true'
apt-get install -y oracle-java8-installer

## Install Elasticsearch
apt-get install -y elasticsearch
sed -i 's/^# network.host: 192.168.0.1/network.host: 192.168.50.7/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/^# http.port: 9200/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml

service elasticsearch restart

apt-get autoremove -y
