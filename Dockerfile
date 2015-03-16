FROM debian:latest

ENV JRUBY_VERSION 1.7.15
ENV APP_ROOT /opt/example/sinatra
ENV STOKESDRIFT_USER stokesdrift

# Setup user
RUN groupadd -r $STOKESDRIFT_USER -g 433 && \
    useradd -u 431 -r -g $STOKESDRIFT_USER -d /tmp -s /sbin/nologin -c "Docker image user" $STOKESDRIFT_USER

RUN apt-get update
# Setup git
RUN apt-get install -y --no-install-recommends ssh
RUN apt-get install -y --no-install-recommends wget
RUN apt-get install -y --no-install-recommends git
RUN apt-get install -y --no-install-recommends unzip

# Setup Jruby env
# TODO Java Policy files?
RUN apt-get install -y --no-install-recommends openjdk-7-jre-headless tar curl && apt-get autoremove -y && apt-get clean
RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH
RUN echo gem: --no-document >> /etc/gemrc
RUN gem update --system
RUN gem install bundler
RUN /bin/ln -s /opt/jruby-$JRUBY_VERSION /opt/jruby


# Setup application
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile $APP_ROOT/
ADD Gemfile.lock $APP_ROOT/

RUN bundle install --without development test darwin

# Add all app files
ADD config.ru $APP_ROOT/
ADD app/ $APP_ROOT/app/
# ADD lib/ $APP_ROOT/lib/
# ADD config/ $APP_ROOT/config/
ADD drift_config.yml $APP_ROOT/
ADD service-start.sh $APP_ROOT/

# SET PERMISSIONS
RUN chown -R $STOKESDRIFT_USER:$STOKESDRIFT_USER $APP_ROOT
RUN chown -R $STOKESDRIFT_USER:$STOKESDRIFT_USER /opt/jruby/
RUN chmod +x $APP_ROOT/service-start.sh

# CLEAN UP
RUN rm $APP_ROOT/Gemfile
RUN rm $APP_ROOT/Gemfile.lock
RUN app-get -y remove git
RUN cat /opt/jruby/bin/stokesdrift

# Debug
RUN which stokesdrift

USER $STOKESDRIFT_USER

# Set default container command
ENTRYPOINT $APP_ROOT/service-start.sh
# ENTRYPOINT /bin/bash