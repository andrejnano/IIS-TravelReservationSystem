FROM php:7.1.8-apache

LABEL maintainer="xnanoa00@stud.fit.vutbr.cz"

# copy project source files to the host container
COPY . /srv/app

# overwrite the default VirtualHosts by Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# give ownership of the project files to Apache 'www-data' user
RUN chown -R www-data:www-data /srv/app && a2enmod rewrite
