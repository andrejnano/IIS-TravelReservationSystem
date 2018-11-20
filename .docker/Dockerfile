# official image, PHP stable version + Apache server
FROM php:7.2.10-apache

# meta data
LABEL name="IIS Projekt"
LABEL maintainer="xnanoa00@stud.fit.vutbr.cz"
LABEL repository="https://github.com/andrejnano/IIS-projekt"

# copy project source files to the host container
COPY . /srv/app

# overwrite the default VirtualHosts by Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# sets the path where commands executing on the container will run
# also sets the starting path when entering the container with bash
WORKDIR /srv/app

# install PHP extensions for MySQL usage
RUN docker-php-ext-install mbstring pdo pdo_mysql mysqli

# give ownership of the project files to Apache 'www-data' user
RUN chown -R www-data:www-data /srv/app

RUN a2enmod rewrite