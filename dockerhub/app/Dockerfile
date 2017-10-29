FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get install -y git sudo curl

# === useradd

RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
RUN useradd -d /home/isucon -m -s /bin/bash isucon
RUN echo isucon:isucon | chpasswd
RUN echo 'isucon ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# === build app

USER isucon

RUN git clone https://github.com/isucon/isucon7-qualify.git /tmp/isubata

RUN sudo apt-get install -y libreadline-dev pkg-config autoconf automake build-essential libmysqlclient-dev \
    libssl-dev python3 python3-dev python3-venv openjdk-8-jdk-headless libxml2-dev libcurl4-openssl-dev \
    libxslt1-dev re2c bison libbz2-dev libreadline-dev libssl-dev gettext libgettextpo-dev libicu-dev \
    libmhash-dev libmcrypt-dev libgd-dev libtidy-dev

WORKDIR /home/isucon

RUN git clone https://github.com/tagomoris/xbuild.git
RUN mkdir local
RUN xbuild/ruby-install   -f 2.4.2   /home/isucon/local/ruby
RUN xbuild/perl-install   -f 5.26.1  /home/isucon/local/perl
RUN xbuild/node-install   -f v6.11.4 /home/isucon/local/node
RUN xbuild/go-install     -f 1.9     /home/isucon/local/go
RUN xbuild/python-install -f 3.6.2   /home/isucon/local/python
RUN xbuild/php-install    -f 7.1.9   /home/isucon/local/php -- --disable-phar --with-pcre-regex --with-zlib --enable-fpm --enable-pdo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl --with-pcre-regex --with-pcre-dir --with-libxml-dir --enable-opcache --enable-bcmath --with-bz2 --enable-calendar --enable-cli --enable-shmop --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-mbregex --enable-mbstring --with-mcrypt --enable-pcntl --enable-sockets --with-curl --enable-zip --with-pearAA


# === build bench

ENV PATH $PATH:/home/isucon/local/go/bin
ENV PATH $PATH:/home/isucon/go/bin

RUN go get github.com/constabulary/gb/...

WORKDIR /tmp/isubata/bench

RUN gb vendor restore
RUN make

RUN /tmp/isubata/bench/bin/gen-initial-dataset

# === setup nginx

RUN sudo apt-get install -y nginx

RUN sudo touch /var/log/nginx/error.log
RUN sudo chown isucon:isucon /var/log/nginx/error.log
RUN sudo chmod 777 /var/log/nginx/error.log

RUN sudo cp /tmp/isubata/files/app/nginx.* /etc/nginx/sites-available
WORKDIR /etc/nginx/sites-enabled
RUN sudo unlink default
RUN sudo ln -s /etc/nginx/sites-available/nginx.conf

RUN sudo /etc/init.d/nginx start


# === setup mysql client

RUN sudo apt-get install -y mysql-client-5.7


# === install utils

RUN sudo apt-get install -y iputils-ping net-tools wget vim jq

WORKDIR /home/isucon/isubata