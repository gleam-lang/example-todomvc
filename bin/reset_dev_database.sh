#!/bin/sh

set -eu
export PGUSER=postgres
export PGPASSWORD=postgres
export PGHOST=localhost

reset() {
  local database=$1
  echo "Resetting $database"
  dropdb "$database" --if-exists
  createdb "$database" 2>&1 >/dev/null || true
}

reset gleam_todomvc_dev
reset gleam_todomvc_test
