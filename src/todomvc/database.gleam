import todomvc/error.{AppError}
import todomvc/log
import gleam/dynamic
import gleam/string
import gleam/result
import gleam/pgo

/// Run some idempotent DDL to ensure we have the PostgreSQL database schema
/// that we want. This should be run when the application starts.
pub fn migrate_schema(db: pgo.Connection) -> Result(Nil, AppError) {
  try _ =
    exec(
      db,
      "create_table_users",
      "create table if not exists users (
        id serial primary key
      )",
    )

  try _ =
    exec(
      db,
      "create_table_items",
      "create table if not exists items (
      id serial
        primary key,

      inserted_at timestamp
        default now(),

      completed boolean 
        not null
        default false,

      content varchar(500)
        not null
        check (content != ''),

      user_id integer
        references users (id)
    )",
    )

  try _ =
    exec(
      db,
      "create_index_items_user_id_completed",
      "create index if not exists items_user_id_completed 
      on items (
        user_id, 
        completed
      )",
    )

  Ok(Nil)
}

fn exec(db: pgo.Connection, name: String, sql: String) -> Result(Nil, AppError) {
  log.info(string.concat(["Running migration ", name]))
  try _ =
    pgo.execute(sql, on: db, with: [], expecting: dynamic.dynamic)
    |> result.map_error(error.PgoError)
  Ok(Nil)
}
