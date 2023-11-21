import sqlight
import todomvc/database
import todomvc/web.{type Context, Context}

pub fn with_context(test: fn(Context) -> t) -> t {
  use db <- with_db("")
  let context = Context(db: db, user_id: 0, static_path: "priv/static")
  test(context)
}

pub fn with_db(name: String, f: fn(sqlight.Connection) -> a) -> a {
  use db <- database.with_connection(name)
  let assert Ok(_) = database.migrate_schema(db)
  f(db)
}
