import gleam/http/response.{Response}
import gleam/http/request.{Request}
import gleam/http/service.{Service}
import gleam/bit_builder.{BitBuilder}
import gleam/erlang/file
import gleam/result
import gleam/string

pub fn middleware(service: Service(in, BitBuilder)) -> Service(in, BitBuilder) {
  fn(request: Request(in)) -> Response(BitBuilder) {
    let path =
      string.concat([
        priv_directory(),
        "/static/",
        string.replace(in: request.path, each: "..", with: ""),
      ])

    let file_contents =
      path
      |> file.read_bits
      |> result.nil_error
      |> result.map(bit_builder.from_bit_string)

    let content_type = case string.ends_with(request.path, ".css") {
      True -> "text/css"
      False -> "text/plain"
    }

    case file_contents {
      Ok(bits) -> Response(200, [#("content-type", content_type)], bits)
      Error(_) -> service(request)
    }
  }
}

external fn priv_directory() -> String =
  "todomvc_ffi" "priv_directory"
