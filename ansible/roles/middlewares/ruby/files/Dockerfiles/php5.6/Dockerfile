FROM php:5.6.15

RUN mkdir /root/ansible
WORKDIR /root/ansible

ADD php/composer.json /var/tmp/

RUN apt-get update \
  && apt-get install -y sudo gcc git python-dev python-setuptools python-pip \
  && pip install markupsafe ansible \
  && curl -s http://getcomposer.org/installer | php && mv -f composer.phar /usr/bin/composer
