import gleam/http/response.{Response}
import gleam/string_builder.{StringBuilder}
import gleam/string

pub type Error {
  NotFound
}

pub type Result =
  Result(Response(StringBuilder), Error)

pub fn result_to_response(result: Result) -> Response(StringBuilder) {
  case result {
    Ok(response) -> response
    Error(error) -> error_to_response(error)
  }
}

pub fn error_to_response(error: Error) -> Response(StringBuilder) {
  case error {
    NotFound ->
      response.new(404)
      |> response.set_body(string_builder.from_string("There's nothing here..."))
  }
}

pub fn html_response(
  html: StringBuilder,
  status: Int,
) -> Response(StringBuilder) {
  response.new(status)
  |> response.prepend_header("content-type", "text/html")
  |> response.set_body(html)
}

pub fn escape(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
}
