# Use ARG to define PHP version with a default value
ARG PHP_VERSION=8.0

# Use the ARG in the FROM instruction
FROM webdevops/php-apache-dev:${PHP_VERSION} AS base

# Install git
RUN apt-get update && apt-get install -y git

# Set the working directory
WORKDIR /app

RUN mkdir /root/.ssh/

RUN touch /root/.ssh/known_hosts

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Clone the repository
RUN RUN --mount=type=ssh git clone git@github.com:GhentCDH/ugent-huisstijl-2016-bootstrap3.git .

RUN echo "this worked"

# Multi-stage build
FROM webdevops/php-apache-dev:${PHP_VERSION}

# Copy files from the previous stage (ssh key is removed)
COPY --from=base /app /app

# Set the working directory
WORKDIR /app
