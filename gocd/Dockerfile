# GoCD server:
#   docker build --target server -t gocd-server .
#   docker run -itd -p 8153:8153 --network ci --env-file ../.cienv gocd-server
# GoCD agent:
#   docker build --target agent -t gocd-agent .
#   docker run -itd --network ci --env-file ../.cienv gocd-agent

FROM  debian:buster-slim AS builder
LABEL vendor=GoCD \
      maintainer="Nikola Radovanovic <nikoladsp@gmail.com>" \
      org.gocd.license="Apache License, Version 2.0" \
      org.gocd.name="GoCD server"

ENV TERM="xterm"
ENV DEBIAN_FRONTEND noninteractive

ARG VERSION=21.2.0-12498
ARG SERVER_DOWNLOAD_URL=https://download.gocd.org/binaries/${VERSION}/generic/go-server-${VERSION}.zip
ARG AGENT_DOWNLOAD_URL=https://download.gocd.org/binaries/${VERSION}/generic/go-agent-${VERSION}.zip

RUN apt-get update \
 && apt-get install -y --no-install-recommends wget ca-certificates unzip procps \
 && mkdir /artifacts \
 && wget --directory-prefix=/artifacts -qc https://download.java.net/java/GA/jdk15.0.2/0d1cfde4252546c6931946de8db48ee2/7/GPL/openjdk-15.0.2_linux-x64_bin.tar.gz \
 && wget --directory-prefix=/artifacts -qc ${SERVER_DOWNLOAD_URL} \
 && wget --directory-prefix=/artifacts -qc ${AGENT_DOWNLOAD_URL}

COPY run.sh /artifacts
COPY logback.xml /artifacts
COPY agent-bootstrapper-logback.xml /artifacts
COPY cruise-config.in.xml /artifacts
COPY db.in.properties /artifacts


# create GoCD server container
FROM  debian:buster-slim AS server

# JAVA related settings
ENV JAVA_HOME=/opt/jdk-15.0.2
ENV PATH=${JAVA_HOME}/bin:$PATH
# PostgreSql backend settings
ENV DB_HOST=${DB_HOST:-db}
ENV DB_PORT=${DB_PORT:-5432}
ENV DB_NAME=${DB_NAME:-gocd}
ENV DB_USERNAME=${DB_USERNAME:-admin}
ENV DB_PASSWORD=${DB_PASSWORD:-pwd123}
# GoCD configuration settings
ENV AGENT_REGISTER_KEY=${AGENT_REGISTER_KEY:-}

COPY --from=builder /artifacts/* /opt/

RUN apt-get update \
 && apt-get install -y --no-install-recommends gettext unzip procps git python3-dev python3-pip python3-setuptools python3-wheel \
 && mv /opt/run.sh /run.sh \
 && tar -xzf /opt/openjdk-15.0.2_linux-x64_bin.tar.gz -C /opt \
 && unzip '/opt/go-server*.zip' -d /opt \
 && (cd /opt/go-server*/ && mkdir -p config) \
 && mv /opt/logback.xml /opt/go-server-*/config/ \
 && mv /opt/cruise-config.in.xml /opt/go-server-*/config/ \
 && mv /opt/db.in.properties /opt/go-server-*/config/ \
 && mkdir -p /artifacts \
# clean
 && rm -rf /opt/*.zip /opt/*.tar.gz /opt/*.xml \
 && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/*

VOLUME ["/artifacts"]

EXPOSE 8153

CMD ["/run.sh"]

# create GoCD agent container
FROM  debian:buster-slim AS agent

# JAVA related settings
ENV JAVA_HOME=/opt/jdk-15.0.2
ENV PATH=${JAVA_HOME}/bin:$PATH

# GoCD configuration settings
ENV GOCD_SERVER=${GOCD_SERVER:-gocd-server}
ENV AGENT_REGISTER_KEY=${AGENT_REGISTER_KEY:-}

COPY --from=builder /artifacts/* /opt/

RUN apt-get update \
 && apt-get install -y --no-install-recommends gettext unzip procps git locales build-essential python3-dev python3-pip python3-setuptools python3-wheel python3-venv libpng-dev libfreetype6-dev libssl-dev rustc cargo \
 && pip3 install docutils setuptools-rust twine \
 && mv /opt/run.sh /run.sh \
 && tar -xzf /opt/openjdk-15.0.2_linux-x64_bin.tar.gz -C /opt \
 && unzip '/opt/go-agent*.zip' -d /opt \
 && (cd /opt/go-agent*/ && mkdir -p config) \
 && mv /opt/agent-bootstrapper-logback.xml /opt/go-agent-*/config/ \
# clean
 && rm -rf /opt/*.zip /opt/*.tar.gz /opt/*.xml \
 && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/*

CMD ["/run.sh", "agent"]
