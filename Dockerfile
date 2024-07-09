# Use ARG to define PHP version with a default value
ARG PHP_VERSION=8.0

# Use the ARG in the FROM instruction
FROM webdevops/php-apache-dev:${PHP_VERSION} AS base

# Install git and ssh client
RUN apt-get update && apt-get install -y git openssh-client

# Set the working directory
WORKDIR /app

# Add GitHub.com to known hosts for SSH
RUN mkdir -p /root/.ssh/ && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

# Clone the repository using SSH
# Note: The --mount=type=ssh flag should be used in the docker build command, not here
RUN git clone git@github.com:GhentCDH/ugent-huisstijl-2016-bootstrap3.git .

# Multi-stage build to ensure SSH keys are not included in the final image
FROM webdevops/php-apache-dev:${PHP_VERSION}

# Copy files from the previous stage
COPY --from=base /app /app

# Set the working directory
WORKDIR /app
