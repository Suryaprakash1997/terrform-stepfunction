FROM ghcr.io/runatlantis/atlantis:latest

USER root

# Install Terragrunt
ARG TERRAGRUNT_VERSION=v0.52.4
RUN curl -L -s --output /tmp/terragrunt \
    https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    chmod +x /tmp/terragrunt && \
    mv /tmp/terragrunt /usr/local/bin/terragrunt

USER atlantis