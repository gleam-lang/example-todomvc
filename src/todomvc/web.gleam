import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/http/service.{Service}
import gleam/bit_builder.{BitBuilder}
import todomvc/web/static
import todomvc/web/logger
import todomvc/web/templates/home as home_template
import gleam/erlang/file
import gleam/string

fn router(request: Request(BitString)) -> Response(BitBuilder) {
  case request.path_segments(request) {
    [] -> home()
    _ -> not_found()
  }
}

fn home() {
  let html = home_template.render_builder()
  response.new(200)
  |> response.set_body(html)
  |> response.map(bit_builder.from_string_builder)
}

fn not_found() -> Response(BitBuilder) {
  response.new(404)
  |> response.set_body("There's nothing here...")
  |> response.map(bit_builder.from_string)
}

pub fn service() -> Service(BitString, BitBuilder) {
  router
  |> service.prepend_response_header("made-with", "Gleam")
  |> logger.middleware
  |> static.middleware()
}
