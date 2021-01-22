#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

DOGU=redmine

docker cp ../ "${DOGU}:/usr/share/webapps/${DOGU}/plugins/redmine_extended_rest_api"
docker restart "${DOGU}"

echo "wait until ${DOGU} passes all health checks"
if ! cesapp healthy --wait --timeout 180 "${DOGU}"; then
  echo "timeout reached by waiting of ${DOGU} to get healthy"
  exit 1
fi
