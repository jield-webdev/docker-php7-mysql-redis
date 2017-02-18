FROM debian:jessie

# With inspiration from https://github.com/punkstar/bitbucket-pipelines-php7-mysql

MAINTAINER Johan van der Heide <info@jield.nl>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

# Base
RUN \
 apt-get update && \
 apt-get -y --no-install-recommends install wget locales apt-transport-https lsb-release apt-utils curl ca-certificates openssh-client && \
 echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
 locale-gen en_US.UTF-8 && \
 /usr/sbin/update-locale LANG=en_US.UTF-8 && \
 update-ca-certificates

#sury and dotdeb resources
RUN \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list && \
  echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list.d/jessie-backports.list && \
  echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb http://packages.dotdeb.org jessie-nginx-http2 all" >> /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb-src http://packages.dotdeb.org jessie-nginx-http2 all" >> /etc/apt/sources.list.d/dotdeb.list && \
  curl https://www.dotdeb.org/dotdeb.gpg | apt-key add - && \
  apt-get update && \
  apt-get -y --no-install-recommends upgrade

#Install nginx-full
RUN \
    apt-get -y -t jessie-backports install "libssl1.0.0" && \
    apt-get install -y nginx-full

#Setup SSH credentials for GitHub
RUN \
 ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P "" && \
 ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

# Install MySQL
RUN \
  echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
  echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
  apt-get install -y mysql-server mysql-client

# Install REDIS
RUN \
  apt-get install -y redis-server

# Install PHP
RUN \
  apt-get install -y git zip && \
  apt-get install -y php7.1-fpm php7.1-cli php7.1-common php7.1-intl php7.1-redis php7.1.gd php7.1-mcrypt php7.1-igbinary php7.1-mysql php7.1-mbstring php7.1-zip php7.1-xml php7.1-curl php7.1-json php7.1-opcache php7.1-readline php7.1-soap

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin

#Install SOLR
RUN \
  wget http://apache.cs.uu.nl/lucene/solr/6.4.1/solr-6.4.1.tgz && \
  apt-get -y install default-jre && \
  tar -zxvf solr-6.4.1.tgz && \
  ./solr-6.4.1/bin/install_solr_service.sh solr-6.4.0.tgz

  #Cleanup apt
RUN \
  apt-get autoclean && apt-get clean && apt-get autoremove && \

