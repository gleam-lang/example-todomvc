import gleam/http/response.{Response}
import gleam/http/request.{Request}
import gleam/http/service.{Service}
import gleam/bit_builder.{BitBuilder}
import gleam/erlang/file
import gleam/result
import gleam/string

pub fn middleware(service: Service(in, BitBuilder)) -> Service(in, BitBuilder) {
  fn(request: Request(in)) -> Response(BitBuilder) {
    case get_asset(request) {
      Ok(bits) -> Response(200, [], bits)
      Error(_) -> service(request)
    }
  }
}

fn get_asset(request: Request(in)) -> Result(BitBuilder, Nil) {
  request.path
  |> string.replace("..", "")
  |> string.append("priv/static/", _)
  |> file.read_bits
  |> result.nil_error
  |> result.map(bit_builder.from_bit_string)
}
