#!/bin/sh

set -eu

reset() {
  local database=$1
  echo
  echo "Resetting $database"
  dropdb "$database" --if-exists
  createdb "$database" 2>&1 >/dev/null || true

  for migration in $(ls migrations)
  do
    echo "> $migration"
    pgexec "$database" "migrations/$migration/up.sql"
  done
}

# https://petereisentraut.blogspot.com/2010/03/running-sql-scripts-with-psql.html
pgexec() {
  PGOPTIONS="--client-min-messages=warning" \
    psql -X -1 -v ON_ERROR_STOP=1 \
    --pset pager=off \
    -d "$1" \
    --file "$2"
}

reset gleam_todomvc_dev
reset gleam_todomvc_test
