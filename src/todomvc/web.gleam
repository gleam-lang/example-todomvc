//// Various helper functions for use in the web interface of the application.
////

import gleam/http.{Http}
import gleam/http/cookie
import gleam/http/response.{Response}
import gleam/http/request.{Request}
import gleam/uri
import gleam/string_builder.{StringBuilder}
import gleam/option.{Option}
import gleam/string
import gleam/result
import gleam/list
import gleam/int
import gleam/pgo
import gleam/crypto
import todomvc/error.{AppError}
import todomvc/user
import todomvc/log

pub type AppRequest {
  AppRequest(
    method: http.Method,
    path: List(String),
    headers: List(#(String, String)),
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
      option.None -> {
        log.info("Creating a new user")
        #(user.insert_user(db), True)
      }
      option.Some(id) -> #(id, False)
    }

    try response =
      service(AppRequest(
        method: request.method,
        path: request.path_segments(request),
        headers: request.headers,
        body: request.body,
        db: db,
        user_id: id,
      ))

    case new_user {
      True ->
        <<int.to_string(id):utf8>>
        |> crypto.sign_message(<<secret:utf8>>, crypto.Sha256)
        |> response.set_cookie(response, "uid", _, cookie.defaults(Http))
        |> Ok
      False -> Ok(response)
    }
  }
}

/// Fetch the current user's id number from the `uid` cookie, returning `None`
/// if there is none.
///
/// The cookie's value is signed and if it is found to have been tampered with
/// then an error is returned.
///
pub fn user_id_from_cookies(
  request: Request(t),
  secret: String,
) -> Result(Option(Int), AppError) {
  case list.key_find(request.get_cookies(request), "uid") {
    Ok(id) -> {
      let id = user.verify_cookie_id(id, secret)
      result.map(id, option.Some)
    }
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

/// Return an appropriate HTTP response for a given error.
///
pub fn error_to_response(error: AppError) -> Response(StringBuilder) {
  case error {
    error.UserNotFound -> user_not_found()
    error.NotFound -> not_found()
    error.MethodNotAllowed -> method_not_allowed()
    error.BadRequest -> bad_request()
    error.UnprocessableEntity | error.ContentRequired -> unprocessable_entity()
    error.PgoError(_) -> internal_server_error()
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
  |> string.replace("\"", "&quot;")
}

pub fn not_found() -> Response(StringBuilder) {
  let body = string_builder.from_string("There's nothing here...")
  response.new(404)
  |> response.set_body(body)
}

pub fn user_not_found() -> Response(StringBuilder) {
  let attributes =
    cookie.Attributes(..cookie.defaults(Http), max_age: option.Some(0))
  not_found()
  |> response.set_cookie("uid", "", attributes)
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

pub fn internal_server_error() -> Response(StringBuilder) {
  let body = string_builder.from_string("Internal server error. Sorry!")
  response.new(500)
  |> response.set_body(body)
}

pub fn unprocessable_entity() -> Response(StringBuilder) {
  let body = string_builder.from_string("Unprocessable entity")
  response.new(422)
  |> response.set_body(body)
}

pub fn parse_urlencoded_body(
  request: AppRequest,
) -> Result(List(#(String, String)), AppError) {
  uri.parse_query(request.body)
  |> result.replace_error(error.BadRequest)
}

pub fn key_find(list: List(#(k, v)), key: k) -> Result(v, AppError) {
  list
  |> list.key_find(key)
  |> result.replace_error(error.UnprocessableEntity)
}

pub fn parse_int(string: String) -> Result(Int, AppError) {
  string
  |> int.parse
  |> result.replace_error(error.BadRequest)
}

pub fn ensure_method(
  request: AppRequest,
  method: http.Method,
) -> Result(Nil, AppError) {
  case request.method == method {
    True -> Ok(Nil)
    False -> Error(error.MethodNotAllowed)
  }
}
