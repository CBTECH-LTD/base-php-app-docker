FROM php:7.4-fpm
LABEL maintainer="Vanderlei Sbaraini Amancio <vanderlei@cbtech.co.uk>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive


### Install required packages

USER root

RUN rm -rf /var/lib/apt/lists/*; \
    apt-get dist-upgrade

RUN set -eux; \
    apt-get update && \
    apt-get install -y gnupg2 && \
    apt-get install -y --no-install-recommends \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libssl-dev \
    libmcrypt-dev \
    libmagickwand-dev \
    zlib1g-dev \
    libicu-dev;

### Install general PHP extensions

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions bcmath intl mcrypt pcntl pdo_pgsql pgsql redis zip exif gd imagick

# Configure PHP-FPM

COPY php-fpm/app.ini /usr/local/etc/php/php.ini

# Install composer from the official image

ENV COMPOSER_MEMORY_LIMIT=-1
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install git

RUN apt-get update; \
    apt-get install -y git

# Instal Nginx

RUN apt-get update && \
    apt-get install -y nginx && \
    rm /etc/nginx/sites-enabled/*

COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Install Supervisor

RUN apt-get update && \
    apt-get install -y supervisor

COPY supervisor/supervisord.conf /etc/supervisord.conf
COPY supervisor/supervisord.d /etc/supervisord.d

# Make sure files/folders needed by the processes are accessable when they run under the nobody user

RUN chown -R www-data:www-data /run && \
    mkdir /usr/local/.nvm && \
    chown -R www-data:www-data /usr/local && \
    chown -R www-data:www-data /var/lib/nginx && \
    chown -R www-data:www-data /var/log/nginx && \
    mkdir -p /app/storage/framework/cache && \
    chmod -R 777 /app/storage && \
    chown -R www-data:www-data /app

# Install nodejs

USER www-data

ENV NODE_VERSION=12.13.0
ENV NVM_DIR=/usr/local/.nvm
ENV PATH="/usr/local/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN mkdir -p $NVM_DIR; \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash; \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION}; \
    nvm use v${NODE_VERSION}; \
    nvm alias default v${NODE_VERSION}

USER root

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn

RUN rm -rf /var/lib/apt/lists/*

# Run command

USER www-data
WORKDIR /app
EXPOSE 8080

CMD ["/usr/bin/supervisord"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
