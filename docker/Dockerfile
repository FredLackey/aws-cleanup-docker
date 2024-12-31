FROM ubuntu:20.04

LABEL maintainer="fred.lackey@gmail.com"
LABEL author="fred.lackey@gmail.com"
LABEL version="202412311253"
LABEL description="AWS Cleanup"

# ------------------------------------------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------------------------------------------

RUN apt update
RUN apt upgrade -y
RUN apt install -y curl software-properties-common wget gnupg unzip vim jq

RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone
RUN apt install -y git-all

# ------------------------------------------------------------------------------------------------
# Install AWS CLI
# ------------------------------------------------------------------------------------------------

RUN apt install -y awscli

# ------------------------------------------------------------------------------------------------
# Install Golang
# ------------------------------------------------------------------------------------------------

RUN mkdir -p /tmp/golang
WORKDIR /tmp/golang
RUN curl -L  https://storage.googleapis.com/golang/go1.23.3.linux-amd64.tar.gz -o /tmp/golang/go.tar.gz
RUN tar xvfz /tmp/golang/go.tar.gz -C /tmp/golang
RUN mv /tmp/golang/go /usr/local/
ENV PATH="/usr/local/go/bin:${PATH}"
RUN go install golang.org/x/tools/cmd/goimports@latest
RUN go install github.com/nsf/gocode@latest
RUN go version

WORKDIR /root
RUN rm -rf /tmp/golang
RUN rm -rf /root/go

# ------------------------------------------------------------------------------------------------
# Install Node
# ------------------------------------------------------------------------------------------------

ENV NODE_VERSION=22.11.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# ------------------------------------------------------------------------------------------------
# Copy in scripts
# ------------------------------------------------------------------------------------------------

WORKDIR /root
COPY scripts/cleanup-instances.sh /root/cleanup-instances.sh
RUN chmod +x /root/cleanup-instances.sh
