import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/http/service.{Service}
import gleam/bit_builder.{BitBuilder}
import todomvc/web/logger
import todomvc/web/templates/home as home_template
import gleam/erlang/file
import gleam/string

fn router(request: Request(BitString)) -> Response(BitBuilder) {
  case request.path_segments(request) {
    [] -> home()
    ["assets", ..asset] -> static_asset(asset)
    _ -> not_found()
  }
}

// TODO: extract into middleware
// TODO: content type
// TODO: test
fn static_asset(asset: List(String)) -> Response(BitBuilder) {
  // Sanitise path
  let path =
    asset
    |> string.join("/")
    |> string.replace("..", "")
    |> string.append("priv/static/assets/", _)
  case file.read_bits(path) {
    Ok(bytes) ->
      response.new(200)
      |> response.set_body(bytes)
      |> response.map(bit_builder.from_bit_string)
    Error(_) -> not_found()
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
}
