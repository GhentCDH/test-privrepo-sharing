# Use ARG to define PHP version with a default value
ARG PHP_VERSION=8.0

# Use the ARG in the FROM instruction
FROM webdevops/php-apache-dev:${PHP_VERSION} AS base

# Install git and ssh client
RUN apt-get update && apt-get install -y git openssh-client

# Set the working directory
WORKDIR /app

COPY --link package.json ./

# Add GitHub.com to known hosts for SSH
RUN mkdir -p /root/.ssh/ && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN set -eux; \
    apt-get update -qq; \
    apt-get install -qq -y curl git apt-transport-https gnupg software-properties-common;

# Install NodeJs 18
RUN set -eux; \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - ; \
    apt-get update -qq; \
    apt-get install -qq -y nodejs;

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN --mount=type=ssh pnpm install
# Multi-stage build to ensure SSH keys are not included in the final image

FROM webdevops/php-apache-dev:${PHP_VERSION}

# Copy files from the previous stage


COPY --from=base /app /app
RUN echo $(ls -a ~/.ssh)
RUN --mount=type=ssh ssh-add -l

# Set the working directory
WORKDIR /app
