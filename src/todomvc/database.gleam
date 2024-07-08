import gleam/result
import sqlight
import todomvc/error.{type AppError}

pub type Connection =
  sqlight.Connection

pub fn with_connection(name: String, f: fn(sqlight.Connection) -> a) -> a {
  use db <- sqlight.with_connection(name)
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on;", db)
  f(db)
}

/// Run some idempotent DDL to ensure we have the PostgreSQL database schema
/// that we want. This should be run when the application starts.
pub fn migrate_schema(db: sqlight.Connection) -> Result(Nil, AppError) {
  sqlight.exec(
    "
    create table if not exists users (
      id integer primary key autoincrement not null
    ) strict;

    create table if not exists items (
     id integer primary key autoincrement not null,

     inserted_at text not null
       default current_timestamp,

     completed integer 
       not null
       default 0,

     content text
       not null
       constraint empty_content check (content != ''),

     user_id integer not null,
     foreign key (user_id)
       references users (id)
    ) strict;

    create index if not exists items_user_id_completed 
    on items (
      user_id, 
      completed
    );",
    db,
  )
  |> result.map_error(error.SqlightError)
}
