import gleam/pgo
import gleam/option

// TODO: make this close the connection even when the test fails
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
  let result = f(db)
  pgo.disconnect(db)
  result
}
