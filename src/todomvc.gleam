import todomvc/web
import gleam/io
import gleam/int
import gleam/string
import gleam/result
import gleam/erlang
import gleam/erlang/os
import gleam/http/elli

pub fn main() {
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(3000)

  // Start the web server process
  assert Ok(_) = elli.start(web.service(), on_port: port)

  io.println(string.concat([
    "Started listening on localhost:",
    int.to_string(port),
    " ✨",
  ]))

  // Put the main process to sleep while the web server does its thing
  erlang.sleep_forever()
}
