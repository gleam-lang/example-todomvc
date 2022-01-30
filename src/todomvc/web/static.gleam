import gleam/http/response.{Response}
import gleam/http/request.{Request}
import gleam/http/service.{Service}
import gleam/erlang/file
import gleam/bit_builder.{BitBuilder}
import gleam/result
import gleam/string

// TODO: Use the Erlang priv dir helper perhaps? That would require Gleam users
// to think about OTP application names, which may not be the nicest experience.
// We could also extract this into a library once we are happy with the API.
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
