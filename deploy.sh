#!/usr/bin/env bash

set -e

# Include common environment variables
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/common.sh

# Deploy versioned Dockerrun.aws.json
function deploy_dockerrun() {
    sed "s/\[VERSION\]/$GIT_COMMIT/g" Dockerrun.aws.json.tpl | \
    aws s3 cp - s3://$S3_RELEASE_BUCKET/Dockerrun-$GIT_COMMIT.aws.json
}

# Create EB version with appropriate Dockerrun.aws.json
function create_eb_version() {
    # Create EB version
    aws elasticbeanstalk --region us-east-1 create-application-version --application-name \
    $1 --version-label $GIT_COMMIT --no-auto-create-application \
    --source-bundle S3Bucket=$S3_RELEASE_BUCKET,S3Key=Dockerrun-$GIT_COMMIT.aws.json
}

# Deploy specific version to specific environment
function eb_deploy() {
    # Deploy version
    aws elasticbeanstalk --region us-east-1 update-environment --environment-name $1 \
    --version-label $GIT_COMMIT
}

# Deploy Dockerrun.aws.json to S3 bucket
deploy_dockerrun

# Create Elastic Beanstalk app version for application named domain-hubot
create_eb_version domain-hubot

# Deploy application version to environment
eb_deploy domain-hubot-env
