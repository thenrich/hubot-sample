#!/usr/bin/env bash

set -e

# Include common environment variables
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/common.sh

docker build -t app-hubot:$GIT_COMMIT .

