
# Using a Private Repository in GitHub Actions

This guide explains how to use a private repository in your GitHub Actions workflow. We will create an SSH key, add it as a deploy key to the private repository, and configure GitHub Actions to use this key.

## Step 1: Create an SSH Key

Generate an SSH key pair on your local machine:

```bash
ssh-keygen -t rsa -b 4096 -C "<your comment>"
```

This command creates a new SSH key, using the provided email as a label. Follow the prompts to save the key to the default location (`~/.ssh/id_rsa`) and set a passphrase.

## Step 2: Add the Deploy Key to the Private Repository

Copy the contents of the public key file (`~/.ssh/id_rsa.pub`) and add it as a deploy key in the settings of your private repository. 

Go to your private repository on GitHub, then navigate to:

```
Settings > Deploy keys > Add deploy key
```

Paste the public key into the "Key" field and give it a title. Make sure to allow write access if necessary. Also note that the same deploy key cannot be used for different repositories. 

## Step 3: Add the Private SSH Key to GitHub Secrets

In your public repository, go to:

```
Settings > Secrets and variables > Actions > New repository secret
```

Add a new secret with the preferred name and paste the contents of your private key file (`~/.ssh/id_rsa`). Note: if you want one secret for all deploy keys, you have to recreate the secret and add all deploy keys as changing a secret is not possible.

Preferably, delete the private key file from your local machine.

## Step 4: Configure GitHub Actions Workflow

Create or update your GitHub Actions workflow file (e.g., `.github/workflows/main.yml`) to use the `webfactory/ssh-agent` action. This action loads your SSH key so that it can be used in subsequent steps.

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.YOUR_SSH_KEY }}

      # Add additional steps here
```

This step sets up the SSH agent and loads the SSH key stored in the GitHub secret.

## Step 5: Building Docker Image with SSH

If you want to build a Docker image and need access to the private repository, use the `docker buildx` command with the `--ssh` flag:

```yaml
      - name: Build Docker image
        run: docker buildx build . --file Dockerfile --ssh default=$SSH_AUTH_SOCK --tag test-image:$(date +%s)
```

The `buildx` command is necessary for the `--ssh` flag, which allows the SSH key to be used within the Docker container during the build process.

### Build and push to Docker Hub

If you also want to push the Docker image to a registry, use the docker/build-push-action action. This action simplifies the process of building and pushing Docker images to a registry. Here's how to integrate it into your workflow:

```yml
name: Build and push

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.YOUR_SSH_KEY }}

      - name: Build and push Docker image
        id: docker_build
        uses: docker/build-push-action@v6
        with:
          ssh: default=$SSH_AUTH_SOCK
          # Additional configuration for pushing to your Docker registry
          push: true
          tags: user/repo:tag

```
## Step 6: Adding GitHub to Known Hosts

To avoid SSH verification prompts, add GitHub.com to known hosts in your Dockerfile:

```Dockerfile
# Add GitHub.com to known hosts for SSH
RUN mkdir -p /root/.ssh/ && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts
```

This ensures that GitHub's SSH key is recognized and trusted within the container.

#### Note: It is good practice to use multi-stage builds to ensure no ssh key is included in the final image!

## Step 7: Using SSH Key in Commands

When running commands that require the SSH key, use the `--mount=type=ssh` option:

```Dockerfile
RUN --mount=type=ssh ssh-add -l
```

This allows the command to use the SSH key loaded by the `webfactory/ssh-agent`.

## Summary

By following these steps, you can securely use a private repository in your GitHub Actions workflow. The SSH key is generated and added as a deploy key to the private repository, stored securely as a secret in GitHub, and used in the workflow to access the repository. Docker builds and other commands requiring the SSH key are configured to use it correctly. Additionally, the guide covers pushing Docker images to a registry.

## Feedback and Improvements

While this guide aims to be comprehensive, there may still be areas for improvement. Contributions and suggestions are always welcome. If you find any errors or have ideas to enhance the explanation, please feel free to open an issue or submit a pull request.
