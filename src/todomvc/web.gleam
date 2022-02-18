//// Various helper functions for use in the web interface of the application.
////

import gleam/http.{Http}
import gleam/http/cookie
import gleam/http/response.{Response}
import gleam/http/request.{Request}
import gleam/string_builder.{StringBuilder}
import gleam/bit_string
import gleam/option.{Option}
import gleam/string
import gleam/result
import gleam/list
import gleam/int
import gleam/pgo
import gleam/crypto
import todomvc/error.{AppError}
import todomvc/user

pub type AppRequest {
  AppRequest(
    method: http.Method,
    path: List(String),
    body: String,
    db: pgo.Connection,
    user_id: Int,
  )
}

/// Load the user from the `uid` cookie if set, otherwise create a new user row
/// and assign that in the response cookies.
///
/// The `uid` cookie is signed to prevent tampering.
///
pub fn authenticate(
  service: fn(AppRequest) -> AppResult,
  secret: String,
  db: pgo.Connection,
) -> fn(Request(String)) -> AppResult {
  fn(request: Request(String)) {
    try id = user_id_from_cookies(request, secret)

    let #(id, new_user) = case id {
      option.None -> #(user.insert_user(db), True)
      option.Some(id) -> #(id, False)
    }

    try response =
      service(AppRequest(
        method: request.method,
        path: request.path_segments(request),
        body: request.body,
        db: db,
        user_id: id,
      ))

    case new_user {
      True ->
        response
        |> response.set_cookie("uid", int.to_string(id), cookie.defaults(Http))
        |> Ok
      False -> Ok(response)
    }
  }
}

pub fn user_id_from_cookies(
  request: Request(t),
  secret: String,
) -> Result(Option(Int), AppError) {
  case list.key_find(request.get_cookies(request), "uid") {
    Ok(id) ->
      crypto.verify_signed_message(id, <<secret:utf8>>)
      |> result.then(bit_string.to_string)
      |> result.then(int.parse)
      |> result.map(option.Some)
      |> result.replace_error(error.BadRequest)
    Error(_) -> Ok(option.None)
  }
}

pub type AppResult =
  Result(Response(StringBuilder), AppError)

pub fn result_to_response(result: AppResult) -> Response(StringBuilder) {
  case result {
    Ok(response) -> response
    Error(error) -> error_to_response(error)
  }
}

pub fn error_to_response(error: AppError) -> Response(StringBuilder) {
  case error {
    error.NotFound | error.UserNotFound -> not_found()
    error.MethodNotAllowed -> method_not_allowed()
    error.BadRequest -> bad_request()
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
  let body = string_builder.from_string("There's nothing here...")
  response.new(404)
  |> response.set_body(body)
}

pub fn method_not_allowed() -> Response(StringBuilder) {
  let body = string_builder.from_string("There's nothing here...")
  response.new(405)
  |> response.set_body(body)
}

pub fn bad_request() -> Response(StringBuilder) {
  let body = string_builder.from_string("Bad request")
  response.new(400)
  |> response.set_body(body)
}
