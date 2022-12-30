import todomvc/web/routes
import todomvc/database
import todomvc/log
import gleam/int
import gleam/string
import gleam/result
import gleam/erlang/os
import gleam/erlang/process
import gleam/option
import gleam/pgo
import mist

pub fn main() {
  log.configure_backend()

  let port = load_port()
  let application_secret = load_application_secret()
  let db = start_database_connection_pool()
  assert Ok(_) = database.migrate_schema(db)
  let handler = routes.app(_, application_secret, db)

  string.concat(["Listening on http://localhost:", int.to_string(port), " ✨"])
  |> log.info

  assert Ok(_) = mist.run_service(port, handler, max_body_limit: 4_000_000_000)
  process.sleep_forever()
}

pub fn start_database_connection_pool() -> pgo.Connection {
  let config =
    os.get_env("DATABASE_URL")
    |> result.then(pgo.url_config)
    // In production we use IPv6
    |> result.map(fn(config) { pgo.Config(..config, ip_version: pgo.Ipv6) })
    |> result.lazy_unwrap(fn() {
      pgo.Config(
        ..pgo.default_config(),
        host: "localhost",
        database: "gleam_todomvc_dev",
        user: "postgres",
        password: option.Some("postgres"),
      )
    })

  pgo.connect(pgo.Config(..config, pool_size: 15))
}

fn load_application_secret() -> String {
  os.get_env("APPLICATION_SECRET")
  |> result.unwrap("27434b28994f498182d459335258fb6e")
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3_000)
}
