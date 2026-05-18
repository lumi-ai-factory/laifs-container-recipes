#!/bin/bash

set -ue

IMAGE_NAME=$1
RELEASE_NAME=$2

SLURM_ACCOUNT=project_xxxxxxxxx     # Replace with Slurm account
SSH_USER=ssh-user                   # Replace with SSH user
SSH_HOST=ssh-host                   # Replace with SSH host

REMOTE_IMAGE_DIR=remote-image-dir   # Replace with image staging directory
REMOTE_TESTS_DIR=remote-tests-dir   # Replace with image tests directory

REMOTE_IMAGE_PATH=$REMOTE_IMAGE_DIR/$IMAGE_NAME

if ! ssh "${SSH_USER}@${SSH_HOST}" test -f $REMOTE_IMAGE_PATH; then
    scp $IMAGE_NAME ${SSH_USER}@${SSH_HOST}:${REMOTE_IMAGE_DIR}
fi

ssh ${SSH_USER}@${SSH_HOST} "cd ${REMOTE_TESTS_DIR} && \
    bash scripts/run_tests.sh ${SLURM_ACCOUNT} ${REMOTE_IMAGE_PATH} ${RELEASE_NAME}"
