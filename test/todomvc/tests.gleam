import gleam/pgo
import gleam/option
import gleam/result
import gleam/erlang/os

pub fn with_db(f: fn(pgo.Connection) -> a) -> a {
  let config =
    pgo.Config(
      ..pgo.default_config(),
      host: "localhost",
      database: "gleam_todomvc_test",
      user: "postgres",
      password: option.Some("postgres"),
      pool_size: 1,
    )
  let db = pgo.connect(config)

  ensure(run: fn() { f(db) }, afterwards: fn() { pgo.disconnect(db) })
}

pub fn truncate_db(db: pgo.Connection) -> Nil {
  let sql = "
truncate
  users,
  items
cascade
"
  assert Ok(_) = pgo.execute(sql, on: db, with: [], expecting: Ok)
  Nil
}

pub external fn ensure(run: fn() -> a, afterwards: fn() -> b) -> a =
  "todomvc_test_helper" "ensure"
