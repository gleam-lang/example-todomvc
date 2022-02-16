import gleam/http/response.{Response}
import gleam/bit_builder.{BitBuilder}

pub fn not_found() -> Response(BitBuilder) {
  response.new(404)
  |> response.set_body("There's nothing here...")
  |> response.map(bit_builder.from_string)
}
