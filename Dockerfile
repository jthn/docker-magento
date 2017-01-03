FROM occitech/magento:php5.5-apache

ENV MAGENTO_VERSION 1.9.2.4

RUN cd /tmp && curl https://codeload.github.com/OpenMage/magento-mirror/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && tar xvf $MAGENTO_VERSION.tar.gz && mv magento-mirror-$MAGENTO_VERSION/* magento-mirror-$MAGENTO_VERSION/.htaccess /var/www/htdocs

RUN chown -R www-data:www-data /var/www/htdocs

RUN echo "alias ll='ls -l'" >> ~/.bashrc

RUN apt-get update && apt-get install -y \
  mysql-client-5.5 \
  libxml2-dev \
  git

RUN docker-php-ext-install soap

# Install modman
COPY ./modman /usr/local/bin/modman
RUN chmod +x /usr/local/bin/modman

# Install template patch
RUN modman init
RUN modman clone template-patch https://gist.github.com/35c0d32dd651c4c8c840.git

COPY ./bin/install-magento /usr/local/bin/install-magento
#COPY redis.conf /var/www/htdocs/app/etc/

RUN chmod +x /usr/local/bin/install-magento

COPY ./sampledata/magento-sample-data-1.9.1.0.tgz /opt/
COPY ./bin/install-sampledata-1.9 /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

VOLUME /var/www/htdocs
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/htdocs/' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/htdocs/' /etc/apache2/sites-available/default-ssl.conf
