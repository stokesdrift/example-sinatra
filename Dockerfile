FROM debian:latest

ENV JRUBY_VERSION 1.7.19
ENV APP_ROOT /opt/example/sinatra
ENV STOKESDRIFT_USER stokesdrift
ENV STOKESDRIFT_VERSION 0.2.3

# Setup user
RUN groupadd -r $STOKESDRIFT_USER -g 433 && \
    useradd -u 431 -r -g $STOKESDRIFT_USER -d /tmp -s /sbin/nologin -c "Docker image user" $STOKESDRIFT_USER

RUN apt-get update
# Setup git
RUN apt-get install -y --no-install-recommends ssh
RUN apt-get install -y --no-install-recommends wget git unzip

# Setup Jruby env
# TODO Java Policy files?
RUN apt-get install -y --no-install-recommends openjdk-7-jre-headless tar curl && apt-get autoremove -y && apt-get clean
RUN apt-get install -y vim
RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH
# RUN echo gem: --no-document >> /etc/gemrc
RUN gem update --system
RUN gem install bundler
RUN /bin/ln -s /opt/jruby-$JRUBY_VERSION /opt/jruby


RUN ls -lR /opt/jruby/bin

# Setup application
RUN mkdir -p $APP_ROOT

# SET PERMISSIONS
RUN chown -R $STOKESDRIFT_USER:$STOKESDRIFT_USER $APP_ROOT
RUN chown -R $STOKESDRIFT_USER:$STOKESDRIFT_USER /opt/jruby/

# USER $STOKESDRIFT_USER
WORKDIR $APP_ROOT

ADD Gemfile $APP_ROOT/
ADD Gemfile.lock $APP_ROOT/

RUN bundle install --without development test darwin
RUN mkdir -p tmp
# ADD tmp/stokesdrift-0.2.3.gem $APP_ROOT/tmp/
# RUN gem install --local $APP_ROOT/tmp/stokesdrift-0.2.3.gem

# Add all app files
ADD config.ru $APP_ROOT/
ADD app/ $APP_ROOT/app/
# ADD lib/ $APP_ROOT/lib/
# ADD config/ $APP_ROOT/config/
ADD drift_config.yml $APP_ROOT/
ADD service-start.sh $APP_ROOT/
# RUN ls -lR /opt/jruby/lib/ruby/

ADD sd_start.sh /opt/jruby/lib/ruby/gems/shared/gems/stokesdrift-$STOKESDRIFT_VERSION/scripts/server_startup.sh

USER root
ADD tmp/stokesdrift /opt/jruby/lib/ruby/gems/shared/bin/stokesdrift
RUN chmod +x $APP_ROOT/service-start.sh
RUN chmod +x /opt/jruby/lib/ruby/gems/shared/bin/stokesdrift
RUN chmod +x /opt/jruby/lib/ruby/gems/shared/gems/stokesdrift-$STOKESDRIFT_VERSION/scripts/server_startup.sh
# USER $STOKESDRIFT_USER
ENV PATH $PATH:/opt/jruby/lib/ruby/gems/shared/bin

# CLEAN UP
# RUN rm $APP_ROOT/Gemfile
# RUN rm $APP_ROOT/Gemfile.lock

# Debug
RUN which stokesdrift

# FOR debug

RUN gem contents stokesdrift

# Set default container command
# ENTRYPOINT $APP_ROOT/service-start.sh
ENTRYPOINT /bin/sh
# ENTRYPOINT ls -l /opt/jruby/lib/ruby/gems/shared