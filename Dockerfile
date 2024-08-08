FROM alpine:3

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=Etc/UTC
ARG ZULU_KEY_SHA256=6c6393d4755818a15cf055a5216cffa599f038cd508433faed2226925956509a
RUN wget --quiet https://cdn.azul.com/public_keys/alpine-signing@azul.com-5d5dc44c.rsa.pub -P /etc/apk/keys/ && \
    echo "${ZULU_KEY_SHA256}  /etc/apk/keys/alpine-signing@azul.com-5d5dc44c.rsa.pub" | sha256sum -c - && \
    apk --repository https://repos.azul.com/zulu/alpine --no-cache add zulu8-jdk~=8.0.422 tzdata
RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk add bash gettext

RUN apk --update --no-cache add \
    bash \
    maven \
    git \
    openssh \
    gnupg \
    vim \
    jq \
    nodejs \
    npm \
    gettext \
    libxml2 \
    libxml2-utils \
    && apk add --no-cache bash gettext

# Clean up
RUN rm -rf /var/cache/apk/*
# Vaadin needs node
RUN apk add --update nodejs npm

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apk --no-cache add git-lfs

COPY ./add-ssh-key.sh /usr/local/bin
COPY ./setup-maven-servers.sh /usr/local/bin
COPY ./release.sh /usr/local/bin
COPY ./settings-template.xml /usr/share/java/maven-3/conf/
COPY ./settings-server-template.xml /usr/share/java/maven-3/conf/
COPY ./simplelogger.properties /usr/share/java/maven-3/conf/logging/simplelogger.properties

ARG SETTINGS_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-template.xml"
ENV SETTINGS_TEMPLATE_FILE=$SETTINGS_TEMPLATE_FILE

ARG SETTINGS_SERVER_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-server-template.xml"
ENV SETTINGS_SERVER_TEMPLATE_FILE=$SETTINGS_SERVER_TEMPLATE_FILE

ARG SETTINGS_FILE="/usr/share/java/maven-3/conf/settings.xml"
ENV SETTINGS_FILE=$SETTINGS_FILE

RUN mkdir /root/.m2

# Initialize Git LFS
RUN git lfs install

# Set default command
CMD ["/bin/bash"]
