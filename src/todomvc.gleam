import todomvc/web/service
import gleam/io
import gleam/int
import gleam/string
import gleam/result
import gleam/erlang
import gleam/erlang/os
import gleam/http/elli
import gleam/option
import gleam/pgo
import gleam/io

pub fn main() {
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(3000)

  // Start the web server process
  assert Ok(_) = elli.start(service.stack(), on_port: port)

  io.println(string.concat([
    "Started listening on localhost:",
    int.to_string(port),
    " ✨",
  ]))

  // Put the main process to sleep while the web server does its thing
  erlang.sleep_forever()
}

pub fn start_database_connection_pool() -> pgo.Connection {
  pgo.connect(
    pgo.Config(
      ..pgo.default_config(),
      host: "localhost",
      database: "gleam_todomvc_dev",
      user: "postgres",
      password: option.Some("postgres"),
      pool_size: 15,
    ),
  )
}
