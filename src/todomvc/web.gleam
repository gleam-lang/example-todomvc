import gleam/http/response.{Response}
import gleam/string_builder.{StringBuilder}
import gleam/string
import todomvc/error.{AppError}

pub type Result =
  Result(Response(StringBuilder), AppError)

pub fn result_to_response(result: Result) -> Response(StringBuilder) {
  case result {
    Ok(response) -> response
    Error(error) -> error_to_response(error)
  }
}

pub fn error_to_response(error: AppError) -> Response(StringBuilder) {
  case error {
    error.NotFound | error.MethodNotAllowed | error.UserNotFound -> not_found()
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

pub fn not_found() -> Response(StringBuilder) {
  response.new(404)
  |> response.set_body(string_builder.from_string("There's nothing here..."))
}

pub fn method_not_allowed() -> Response(StringBuilder) {
  response.new(405)
  |> response.set_body(string_builder.from_string("There's nothing here..."))
}
