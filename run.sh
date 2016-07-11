#!/bin/sh
set -e

if [ -n "$SSH_PRIVATE_KEY" ]; then
  mkdir -p ~/.ssh
  echo "-----BEGIN RSA PRIVATE KEY-----" > ~/.ssh/id_rsa
  echo "$SSH_PRIVATE_KEY" >> ~/.ssh/id_rsa
  echo "-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa
  chmod 0400 ~/.ssh/id_rsa
fi
if [ -n "$SSH_KNOWN_HOSTS" ]; then
  mkdir -p ~/.ssh
  echo "$SSH_KNOWN_HOSTS" > ~/.ssh/known_hosts
  chmod 0644 ~/.ssh/known_hosts
fi

SHA1=
find . -name . -o -prune -delete
git clone --depth=1 "${REPO}" .
while true
do
  if [ "${SHA1}" != "$(git ls-remote --exit-code origin master | awk '{print $1;}')" ]; then
    git fetch --depth=1
    git reset --hard origin/master
    git clean -xdf
    docker-compose pull
    docker-compose build --pull
    docker-compose up -d --remove-orphans
    SHA1="$(git rev-parse HEAD)"
  fi
  if [ "${INTERVAL}" = "-1" ]; then
    exit 0
  fi
  sleep ${INTERVAL}
done
