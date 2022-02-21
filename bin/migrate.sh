#!/bin/sh

set -eu

database=$1

# https://petereisentraut.blogspot.com/2010/03/running-sql-scripts-with-psql.html
pgexec() {
  PGOPTIONS="--client-min-messages=warning" \
    psql -X -1 -v ON_ERROR_STOP=1 \
    --pset pager=off \
    -d "$1" \
    --file "$2"
}

for migration in $(ls migrations)
do
  echo "> $migration"
  pgexec "$database" "migrations/$migration/up.sql"
done
