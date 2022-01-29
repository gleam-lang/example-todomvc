import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/http/service.{Service}
import gleam/bit_builder.{BitBuilder}
import todomvc/web/logger

fn router(request: Request(BitString)) -> Response(String) {
  case request.path_segments(request) {
    _ -> not_found()
  }
}

fn not_found() -> Response(String) {
  response.new(404)
  |> response.set_body("There's nothing here...")
}

pub fn service() -> Service(BitString, BitBuilder) {
  router
  |> service.prepend_response_header("made-with", "Gleam")
  |> service.map_response_body(bit_builder.from_string)
  |> logger.middleware
}
