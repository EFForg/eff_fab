FROM ruby:2.3-slim

RUN mkdir -p /opt/fab
WORKDIR /opt/fab

ARG BUILD_ENV=production

RUN if [ "$BUILD_ENV" = "development" ]; then \
      adduser -Du 1000 -h /opt/fab www-data; \
    else \
      adduser -DS -h /opt/fab www-data; \
    fi

RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libmysqlclient-dev \
  mysql-client \
  libfontconfig \
  nodejs \
  cron

# Create a symlink to what will be the phantomjs exec path
RUN ln -s /phantomjs-2.1.1-linux-x86_64/bin/phantomjs /bin/phantomjs

# Set up phantomjs, making sure to check the known good sha256sum
RUN cd / && curl -sLo phantomjs.tar.bz2 https://github.com/Medium/phantomjs/releases/download/v2.1.1/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  bash -l -c '[ "`sha256sum phantomjs.tar.bz2 | cut -f1 -d" "`" = "86dd9a4bf4aee45f1a84c9f61cf1947c1d6dce9b9e8d2a907105da7852460d2f" ]' && \
  tar -jxvf phantomjs.tar.bz2 > /dev/null && \
  rm phantomjs.tar.bz2

# TODO: put stuff in the crontab
# Set up crontab.
#RUN echo "*/15 * * * * su -s/bin/sh www-data -c \
  #'cd /opt/fab && bundle exec rake blog:update' >>/proc/1/fd/1 2>&1" >>/etc/crontabs/root \

COPY Gemfile* ./
RUN bundle install

COPY . .

RUN if [ "$BUILD_ENV" = "production" ]; \
  then bundle exec rake assets:precompile \
  RAILS_ENV=production \
  SECRET_KEY_BASE=noop; fi

RUN mkdir -p /var/www /opt/fab/files \
  && chown -R www-data /opt/fab/public \
                       /opt/fab/tmp \
                       /var/www \
                       /usr/local/bundle
USER www-data

CMD ["rails", "s", "-b", "0.0.0.0"]
ENTRYPOINT ["/opt/fab/entrypoint.sh"]
