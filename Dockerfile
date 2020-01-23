# Based on: https://github.com/TrafeX/docker-php-nginx/
FROM alpine:3.10

# Install packages
# If needed, add php-mysqlnd  php-pdo
RUN apk --no-cache add php7 php7-fpm nginx supervisor curl composer \
    php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-gd php7-pdo_mysql php7-zip php7-xmlwriter php7-opcache \
    php7-sockets php7-bcmath php7-sodium php-mysqli php7-sqlite3 php7-simplexml php7-posix php7-fileinfo \
    php7-tokenizer php7-redis php7-mailparse && \
    rm -rf /var/cache/apk/*
    
# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
# Remove the default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/00_custom.ini

# Copy self-signed SSL
COPY --chown=nobody ssl /ssl

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN mkdir -p /writable
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody /writable

# Setup document root
RUN mkdir -p /app

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /app
# COPY --chown=nobody app/ /app

# Expose the port(s) nginx is reachable on
EXPOSE 8080 8443

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

