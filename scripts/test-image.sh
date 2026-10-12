#!/bin/bash
#
# Run the image tests on a remote host. The image is copied to the remote host
# unless it is already there, and the tests are run with the test suite on the
# remote host.
#
# Usage: test-image.sh <image file> <release name>
#
# Site specific settings are read from the .env file in the repository root,
# see .env.example. Set LAIFS_ENV_FILE to read them from another file.

set -ue

IMAGE_NAME=$1
RELEASE_NAME=$2

ENV_FILE="${LAIFS_ENV_FILE:-$(dirname "$(realpath "$0")")/../.env}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: $ENV_FILE not found, create it from .env.example" >&2
    exit 1
fi

source "$ENV_FILE"

for var in SLURM_ACCOUNT SSH_USER SSH_HOST REMOTE_IMAGE_DIR REMOTE_TESTS_DIR; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: $var is not set in $ENV_FILE" >&2
        exit 1
    fi
done

REMOTE_IMAGE_PATH=$REMOTE_IMAGE_DIR/$IMAGE_NAME

if ! ssh "${SSH_USER}@${SSH_HOST}" test -f "$REMOTE_IMAGE_PATH"; then
    scp "$IMAGE_NAME" "${SSH_USER}@${SSH_HOST}:${REMOTE_IMAGE_DIR}"
fi

ssh "${SSH_USER}@${SSH_HOST}" "cd ${REMOTE_TESTS_DIR} && \
    bash scripts/run_tests.sh ${SLURM_ACCOUNT} ${REMOTE_IMAGE_PATH} ${RELEASE_NAME}"
