FROM php:7.0.12-fpm-alpine
MAINTAINER Dennis Jarvis <dennis.jarvis@gmail.com>

# Install system-wide dependencies
RUN apk add --no-cache nginx mysql-client supervisor curl \
    bash redis imagemagick-dev

# Install PHP extensions required for WordPress
RUN apk add --no-cache libtool build-base autoconf \
    && docker-php-ext-install \
      -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
      iconv gd mbstring fileinfo curl xmlreader xmlwriter spl ftp mysqli opcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del libtool build-base autoconf

# Set some environment variables for convenience 
ENV WP_ROOT /usr/src/wordpress
ENV WP_VERSION 4.6.1
ENV WP_SHA1 027e065d30a64720624a7404a1820e6c6fff1202
ENV WP_DOWNLOAD_URL https://wordpress.org/wordpress-$WP_VERSION.tar.gz

# Install WordPress
RUN curl -o wordpress.tar.gz -SL $WP_DOWNLOAD_URL \
    && echo "$WP_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C $(dirname $WP_ROOT) \
    && rm wordpress.tar.gz

# Setup a custom user to own the WordPress files for additional security
RUN adduser -D deployer -s /bin/bash -G www-data

# Make sure we're using a local machine wp-content directory for our code
VOLUME /var/www/wp-content
WORKDIR /var/www/wp-content

# Make sure our custom wp-config.php is in the WordPress root directory
COPY wp-config.php $WP_ROOT
RUN chown -R deployer:www-data $WP_ROOT \
    && chmod 640 $WP_ROOT/wp-config.php

# Setup the crontab
COPY cron.conf /etc/crontabs/deployer
RUN chmod 600 /etc/crontabs/deployer

# Install WordPress CLI tool
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Setup our custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY vhost.conf /etc/nginx/conf.d/
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R www-data:www-data /var/lib/nginx

# Let's make sure the DB is up before proceeding with the rest of the install by using our entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]

# supervisord will control our nginx and php-fpm processes as a single unit, failing everything of one of them fails
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisord.conf
COPY stop-supervisor.sh /usr/local/bin/
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]



