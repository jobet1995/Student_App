FROM node:20

ENV SFDX_AUTOUPDATE_DISABLE=true
ENV SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
ENV DEBIAN_FRONTEND=noninteractive
ENV CODE_SERVER_VERSION=3.10.2

RUN useradd -ms /bin/bash salesforceuser

USER salesforceuser
WORKDIR /home/salesforceuser

WORKDIR /home/salesforceuser/app

COPY . .

RUN npm install

RUN sudo chown -R salesforceuser:salesforceuser /home/salesforceuser/app

EXPOSE 8080 8081 8443

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

RUN sudo service postgresql start && \
    sudo -u postgres psql -c "CREATE USER salesforceuser WITH SUPERUSER PASSWORD 'password';" && \
    sudo -u postgres createdb -O salesforceuser salesforcedb

RUN npm install -g typescript eslint

RUN sudo apt-get update && sudo apt-get install -y openjdk-11-jdk

RUN sudo apt-get install -y redis-server && \
    sudo service redis-server start

RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    sudo usermod -aG docker salesforceuser && \
    rm get-docker.sh

CMD ["bash"]

ENTRYPOINT ["sfdx"]