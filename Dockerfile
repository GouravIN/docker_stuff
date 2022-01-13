#Dockerfile for Jenkins image build on top of debian-stretch

FROM debian

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      apt-transport-https \
      build-essential \
      ca-certificates \
      curl \
      dirmngr \
      git \
      gnupg \
      libtool \
      python \
      python-apt \
      wget

# Install PyPI
RUN set -eux; \
  wget --no-verbose \
    -O get-pip.py \
    https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py && \
  rm -f get-pip.py

#Install NodeJS
# should be done by ansible
RUN set -ex \
  && echo "deb https://deb.nodesource.com/node_11.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
  && wget -qO - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y \
      nodejs \
  && rm -rf /var/lib/apt/lists/*

# Install ansible
RUN set -eux; \
  pip install --no-cache-dir ansible

# Copy playbook to the container
COPY ansible /tmp/ansible

# Provisioning with Ansible
# set ulimits -n to workaround problems described here:
# https://github.com/docker/for-linux/issues/502
RUN set -eux; \
  ulimit -n 1024 && \
  cd /tmp/ansible && \
  ansible-playbook -D playbook.yaml

# remove packages no longer required
# ...

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.16.1
COPY tini_pub.gpg ${JENKINS_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
  && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
  && gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg \
  && gpg --verify /sbin/tini.asc \
  && rm -rf /sbin/tini.asc /root/.gnupg \
  && chmod +x /sbin/tini

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.319.1}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=7e4b848a752eda740c2c7a60956bf05d9df42602c805bbaeac897179b630a562

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# Allow graphs etc. to work even when an X server is present
ENV JAVA_OPTS="-Xrs -Xmx16384m -XX:MaxPermSize=4096m -Djava.awt.headless=true"
# fix CSP related problems in in-ui and other html reports
ENV JAVA_OPTS="$JAVA_OPTS -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-same-origin allow-popups allow-scripts; default-src 'self' 'unsafe-inline' data: maxcdn.bootstrapcdn.com\""
# JAVA_ARGS="$JAVA_ARGS -Dhudson.model.ParametersAction.safeParameters=PIPELINE_VERSION"
ENV JAVA_OPTS="$JAVA_OPTS -Dhudson.model.ParametersAction.keepUndefinedParameters=true"
# allow email addresses as usernames
ENV JAVA_OPTS="$JAVA_OPTS -Dhudson.security.HudsonPrivateSecurityRealm.ID_REGEX=[a-zA-Z][a-zA-Z0-9_.@-]+"

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

#Install Ruby version 2.5
# should be done by ansible

RUN \
  apt-get update && apt-get install -y --no-install-recommends --no-install-suggests --force-yes curl bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* && \
  curl -L https://github.com/sstephenson/ruby-build/archive/v20180329.tar.gz | tar -zxvf - -C /tmp/ && \
  cd /tmp/ruby-build-* && ./install.sh && cd / && \
  ruby-build -v 2.5.1 /usr/local && rm -rfv /tmp/ruby-build-* && \
  gem install bundler --no-rdoc --no-ri

#Install Capistrano
# should be done by ansible

RUN gem install net-sftp -v2.0.0 &&\
    gem install net-scp -v1.0.0 &&\
    gem install net-ssh-gateway -v1.1.0 &&\
    gem install capistrano -v2.15.9 &&\
    gem install capistrano_colors -v0.5.5

USER ${user}
ENV USER ${user}

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY tini-shim.sh /bin/tini
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]