# use latest nginx-phpfpm image
FROM tjend/alpine-nginx-phpfpm:latest

RUN \
  # download ttrss to /var/www/localhost/htdocs
  curl -S https://git-gitea.tt-rss.org/fox/tt-rss/archive/master.tar.gz | \
    tar zx -C /var/www/localhost/htdocs --strip-component 1 && \
  # write version file
  echo "$(date -r /var/www/localhost/htdocs/README.md +%Y%m%d%H%M%S%z)-tjend/alpine-nginx-phpfpm-ttrss" > /var/www/localhost/htdocs/version_static.txt && \
  # chown and make ttrss directories writable
  DIRS="cache feed-icons lock" && \
  for DIR in ${DIRS}; do \
    chown -R www-data:www-data /var/www/localhost/htdocs/${DIR}; \
    find /var/www/localhost/htdocs/${DIR} -type f -exec chmod 664 {} \;; \
    find /var/www/localhost/htdocs/${DIR} -type d -exec chmod 775 {} \;; \
  done

# add files from our git repo
ADD rootfs /

# set phpfpm opcache validate timestamps to off for performance reasons
ENV PHPFPM_OPCACHE_VALIDATE_TIMESTAMPS off

# set ttrss default environment variables
ENV TTRSS_DB_HOST=ttrss-db
ENV TTRSS_DB_NAME=ttrss
ENV TTRSS_DB_PASS=ttrss
ENV TTRSS_DB_PORT=5432
ENV TTRSS_DB_USER=ttrss
ENV TTRSS_PHP_EXECUTABLE=/usr/bin/php8
ENV TTRSS_SELF_URL_PATH=http://localhost/
