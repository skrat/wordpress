FROM base/archlinux

# Upgrade & Install packages
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm mariadb nginx php php-fpm unzip
RUN pacman -S --noconfirm supervisor

# Download latest WordPress
WORKDIR /srv/http
RUN curl -O http://wordpress.org/latest.zip && unzip latest.zip && rm latest.zip
RUN chown -R http wordpress/
RUN chgrp -R http wordpress/

# Configure nginx
WORKDIR /etc/nginx
ADD nginx.conf /etc/nginx/nginx.conf
RUN mkdir sites-enabled && mkdir sites-available
ADD wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN ln -s ../sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf

# Configure DB
RUN mysqld_safe & sleep 2 && mysqladmin create wordpress

# Configure PHP
RUN sed -i 's/^;extension=mysql.so/extension=mysql.so/' /etc/php/php.ini
RUN sed -i 's/^;extension=mysqli.so/extension=mysqli.so/' /etc/php/php.ini
RUN sed -i 's/^;extension=mcrypt.so/extension=mcrypt.so/' /etc/php/php.ini

# Configure WordPress
ADD wp-config.php /srv/http/wordpress/wp-config.php

# Configure supervisord
ADD mysqld.ini  /etc/supervisor.d/mysqld.ini
ADD php-fpm.ini /etc/supervisor.d/php-fpm.ini
ADD nginx.ini   /etc/supervisor.d/nginx.ini

EXPOSE 80

CMD supervisord -n -c /etc/supervisord.conf

