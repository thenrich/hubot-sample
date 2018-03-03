#!/usr/bin/env bash

set -e

# Include common environment variables
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/common.sh

# Setup Docker auth
cat <<EOF > ~/.dockercfg
{
    "$DOCKER_REGISTRY_HOST": {
        "auth": "$DOCKER_REGISTRY_AUTH",
        "email": "$DOCKER_REGISTRY_EMAIL"
    }
}
EOF

if [ ! -d ~/.docker ] ; then
    mkdir ~/.docker
fi

cat <<EOF > ~/.docker/config.json
{
    "auths": {
        "$DOCKER_REGISTRY_HOST": {
            "auth": "$DOCKER_REGISTRY_AUTH",
            "email": "$DOCKER_REGISTRY_EMAIL"
        }
    }
}
EOF

# Push image with retries
function push_image() {
    retries=10
    n=0
    until [ $n -ge $retries ]
    do
        docker push $1 && break
        n=$[$n+1]
        sleep 5
    done
}

# Tag docker image with repository path
docker tag app-hubot:$GIT_COMMIT docker.domain.com/app-hubot:$GIT_COMMIT

# Push image to repository
push_image docker.domain.com/app-hubot:$GIT_COMMIT