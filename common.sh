#!/usr/bin/env bash

set -e

# Get short Git commit
GIT_COMMIT=$(git rev-parse --short HEAD)

# Private Docker registry
DOCKER_REGISTRY=docker.domain.com

# Release bucket for Dockerrun.aws.json files 
S3_RELEASE_BUCKET=com.domain.chatbot.releases
