#!/bin/sh
set -e

if [ -z "$SSH_PRIVATE_KEY" ]; then
  mkdir -p ~/.ssh
  echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  chmod 0400 ~/.ssh/id_rsa
fi
if [ -z "$SSH_PUBLIC_KEY" ]; then
  mkdir -p ~/.ssh
  echo "$SSH_PUBLIC_KEY" > ~/.ssh/id_rsa.pub
  chmod 0400 ~/.ssh/id_rsa.pub
fi

SHA1=
rm -rf *
git clone --depth=1 "${REPO}" .
while true
do
  if [ "${SHA1}" != "$(git ls-remote --exit-code origin master | awk '{print $1;}')" ]; then
    git fetch --depth=1
    git reset --hard origin/master
    git clean -xdf
    docker-compose pull
    docker-compose build
    docker-compose up -d --remove-orphans
    SHA1="$(git rev-parse HEAD)"
  fi
  if [ "${INTERVAL}" = "-1" ]; then
    exit 0
  fi
  sleep ${INTERVAL}
done
