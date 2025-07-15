# use latest nginx-phpfpm image
ARG BASE_IMAGE=docker.io/tjend/alpine-nginx-phpfpm:latest
FROM ${BASE_IMAGE}

RUN \
  apk --no-cache add git && \
  # remove /var/www
  rm -rf /var/www && \
  # download ttrss to /var/www
  git clone --depth 1 https://git.tt-rss.org/fox/tt-rss.git /var/www && \
  # write version file
  echo "$(date -r /var/www/README.md +%Y%m%d%H%M%S%z)-tjend/alpine-nginx-phpfpm-ttrss" > /var/www/version_static.txt && \
  # chown and make ttrss directories writable
  DIRS="cache feed-icons lock" && \
  for DIR in ${DIRS}; do \
    chown -R www-data:www-data /var/www/${DIR}; \
    find /var/www/${DIR} -type f -exec chmod 664 {} \;; \
    find /var/www/${DIR} -type d -exec chmod 775 {} \;; \
  done && \
  apk del git

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
ENV TTRSS_PHP_EXECUTABLE=/usr/bin/php
ENV TTRSS_SELF_URL_PATH=http://localhost/
