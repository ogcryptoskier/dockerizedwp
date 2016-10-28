#!/bin/bash

set -e # terminate on errors

function test_mysql {
  mysqladmin -h "${DB_HOST}" ping
}

until (test_mysql); do
  >&2 echo "MySQL unavailable - sleeping."
  sleep 3
done

>&2 echo "MySQL is up - executing command."

exec "$@"