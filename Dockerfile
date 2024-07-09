# Use ARG to define PHP version with a default value
ARG PHP_VERSION=8.0

# Use the ARG in the FROM instruction
FROM webdevops/php-apache-dev:${PHP_VERSION} AS base

# Install git
RUN apt-get update && apt-get install -y git

# Set the working directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/GhentCDH/ugent-huisstijl-2016-bootstrap3.git .

RUN echo "this worked"

# Multi-stage build
FROM webdevops/php-apache-dev:${PHP_VERSION}

# Copy files from the previous stage
COPY --from=base /app /app

# Set the working directory
WORKDIR /app
