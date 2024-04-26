# create from debian image
FROM debian:latest

# install apache2, php, mod_php for apache2, php-mysql, mariadb, and supervisor
RUN apt-get update && \
    apt-get install -y apache2 php libapache2-mod-php php-mysql mariadb-server supervisor && \
    apt-get clean

# create mysql socket directory and set permissions
RUN mkdir /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# add wordpress files to /var/www/html
RUN curl -o wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz" && \
    tar -xzf wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    rm wordpress.tar.gz && \
    chown -R www-data:www-data /var/www/html

# copy configuration files
COPY files/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY files/apache2/apache2.conf /etc/apache2/apache2.conf
COPY files/php/php.ini /etc/php/7.4/apache2/php.ini
COPY files/mariadb/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY files/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# open port 80
EXPOSE 80

# run supervisord
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# mount volumes
VOLUME /var/lib/mysql
VOLUME /var/log