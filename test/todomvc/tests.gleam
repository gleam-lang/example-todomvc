import gleam/pgo
import gleam/option
import gleam/result
import gleam/erlang/os
import gleam/string_builder
import gleam/http
import gleam/http/response.{Response}
import todomvc/web
import todomvc/error.{AppError}
import todomvc/web/routes

pub fn request(
  method method: http.Method,
  path path: List(String),
  body body: String,
  user_id user_id: Int,
  db db: pgo.Connection,
) -> Result(Response(String), AppError) {
  try response =
    web.AppRequest(
      method: method,
      path: path,
      body: body,
      headers: [],
      user_id: user_id,
      db: db,
    )
    |> routes.router

  response
  |> response.map(string_builder.to_string)
  |> Ok
}

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
