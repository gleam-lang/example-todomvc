import todomvc/web/routes
import todomvc/database
import todomvc/log
import gleam/int
import gleam/string
import gleam/result
import gleam/erlang/os
import gleam/erlang/process
import mist

pub fn main() {
  log.configure_backend()

  let port = load_port()
  let application_secret = load_application_secret()
  let db = "todomvc.sqlite3"
  assert Ok(_) = database.with_connection(db, database.migrate_schema)
  let handler = routes.app(_, application_secret, db)

  string.concat(["Listening on http://localhost:", int.to_string(port), " ✨"])
  |> log.info

  assert Ok(_) = mist.run_service(port, handler, max_body_limit: 4_000_000_000)
  process.sleep_forever()
}

fn load_application_secret() -> String {
  os.get_env("APPLICATION_SECRET")
  |> result.unwrap("27434b28994f498182d459335258fb6e")
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}
