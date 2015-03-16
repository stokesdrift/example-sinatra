#!/bin/bash
export JRUBY_HOME=/opt/jruby/
export PATH=/opt/jruby/bin:$PATH

export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-amd64"

export JAVA_OPTS="-XX:ReservedCodeCacheSize=256m -Xmx2048m -Xms512m -XX:+UseG1GC"
export JAVA_OPTS="${JAVA_OPTS} -XX:+TieredCompilation"
export JAVA_OPTS="${JAVA_OPTS} -XX:+UseCodeCacheFlushing"
export JAVA_OPTS="${JAVA_OPTS} -Djruby.thread.pooling=true"
export JAVA_OPTS="${JAVA_OPTS} -Djruby.compile.positionless=true"
export JAVA_OPTS="${JAVA_OPTS} -Djruby.compile.mode=FORCE"
# export JAVA_OPTS="${JAVA_OPTS} -Djruby.native.enabled=false"
export JAVA_OPTS="${JAVA_OPTS} -Djruby.thread.pool.min=10"
export JAVA_OPTS="${JAVA_OPTS} -XX:CompileCommand=dontinline,org.jruby.runtime.invokedynamic.InvokeDynamicSupport::invocationFallback"
export JAVA_OPTS="${JAVA_OPTS} -Djruby.management.enabled=false"
export JAVA_OPTS="${JAVA_OPTS} -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true"
export JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"

export GEM_PATH=/opt/jruby/lib/ruby/gems/shared/gems

stokesdrift # java $JAVA_OPTS org.stokesdrift.Server
