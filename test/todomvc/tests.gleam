import sqlight
import gleam/string_builder
import gleam/http
import gleam/http/response.{Response}
import todomvc/database
import todomvc/web
import todomvc/web/routes

pub fn request(
  method method: http.Method,
  path path: List(String),
  body body: String,
  user_id user_id: Int,
  db db: String,
) -> Response(String) {
  let response =
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
}

pub fn with_db(name: String, f: fn(sqlight.Connection) -> a) -> a {
  use db <- database.with_connection(name)
  let assert Ok(_) = database.migrate_schema(db)
  f(db)
}

pub fn truncate_db(db: sqlight.Connection) -> Nil {
  let sql =
    "
truncate
  users,
  items
cascade
"
  let assert Ok(_) = sqlight.query(sql, on: db, with: [], expecting: Ok)
  Nil
}

pub external fn ensure(run: fn() -> a, afterwards: fn() -> b) -> a =
  "todomvc_test_helper" "ensure"
