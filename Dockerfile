FROM debian:bullseye-slim

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    bash \
    gettext \
    maven \
    git \
    openssh-client \
    vim \
    jq \
    nodejs \
    npm \
    libxml2-utils \
    curl \
    tar \
    libstdc++6 \
    libgcc1 \
    && rm -rf /var/lib/apt/lists/*

ARG ZULU_VER=8.62.0.19
ARG ZULU_JAVA_VER=8.0.332


RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install locales curl tzdata ca-certificates && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    curl -sLO https://cdn.azul.com/zulu/bin/zulu${ZULU_VER}-ca-fx-jdk${ZULU_JAVA_VER}-linux_amd64.deb && \
    chmod a+rx zulu${ZULU_VER}-ca-fx-jdk${ZULU_JAVA_VER}-linux_amd64.deb && \
    apt-get install -y --no-install-recommends ./zulu${ZULU_VER}-ca-fx-jdk${ZULU_JAVA_VER}-linux_amd64.deb && \
    apt-get -qq -y purge curl && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/* zulu${ZULU_VER}-ca-fx-jdk${ZULU_JAVA_VER}-linux_amd64.deb

ENV JAVA_HOME=/usr/lib/jvm/zulu-fx-8-amd64

#RUN apk add bash gettext

#RUN apk --update --no-cache add \
#    bash \
#    maven \
#    git \
#    openssh \
#    gnupg \
#    vim \
#    jq \
#    nodejs \
#    npm \
#    gettext \
#    libxml2 \
#    libxml2-utils \
#    && apk add --no-cache bash gettext


# Vaadin needs node
#RUN apk add --update nodejs npm

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get update && apt-get install -y git-lfs

# Copy necessary scripts and templates
COPY ./add-ssh-key.sh /usr/local/bin
COPY ./setup-maven-servers.sh /usr/local/bin
COPY ./release.sh /usr/local/bin
COPY ./settings-template.xml /usr/share/java/maven-3/conf/
COPY ./settings-server-template.xml /usr/share/java/maven-3/conf/
COPY ./settings-mirror-template.xml /usr/share/java/maven-3/conf/
COPY ./simplelogger.properties /usr/share/java/maven-3/conf/logging/simplelogger.properties

# Define ARGs and ENV variables for settings files
ARG SETTINGS_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-template.xml"
ENV SETTINGS_TEMPLATE_FILE=$SETTINGS_TEMPLATE_FILE

ARG SETTINGS_SERVER_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-server-template.xml"
ENV SETTINGS_SERVER_TEMPLATE_FILE=$SETTINGS_SERVER_TEMPLATE_FILE

# Adding the mirror template ARG and ENV
ARG SETTINGS_MIRROR_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-mirror-template.xml"
ENV SETTINGS_MIRROR_TEMPLATE_FILE=$SETTINGS_MIRROR_TEMPLATE_FILE

ARG SETTINGS_FILE="/usr/share/java/maven-3/conf/settings.xml"
ENV SETTINGS_FILE=$SETTINGS_FILE


RUN mkdir /root/.m2

RUN mkdir -p ~/.m2

# Initialize Git LFS
RUN git lfs install

# Set default command
CMD ["/bin/bash"]
