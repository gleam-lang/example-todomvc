import gleam/http
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/http/service.{Service}
import gleam/int
import gleam/io
import gleam/string
import gleam/string_builder

fn format_log_line(request: Request(a), response: Response(b)) -> String {
  request.method
  |> http.method_to_string
  |> string.uppercase
  |> string_builder.from_string
  |> string_builder.append(" ")
  |> string_builder.append(int.to_string(response.status))
  |> string_builder.append(" ")
  |> string_builder.append(request.path)
  |> string_builder.to_string
}

pub fn middleware(service: Service(a, b)) -> Service(a, b) {
  fn(request) {
    let response = service(request)
    io.println(format_log_line(request, response))
    response
  }
}
