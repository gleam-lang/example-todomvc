import todomvc/web/static
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/bit_builder
import gleeunit/should

fn app(request: Request(String)) {
  use <- static.middleware(request)
  Response(418, [], bit_builder.from_string("I'm a teapot"))
}

pub fn non_matching_fall_through_test() {
  let response = app(request.new())

  response.status
  |> should.equal(418)
}

pub fn assets_are_served_test() {
  let response =
    request.new()
    |> request.set_path("assets/favicon.ico")
    |> app

  response.status
  |> should.equal(200)
}

pub fn dotdot_is_ineffective_test() {
  let response =
    request.new()
    |> request.set_path("../../gleam.toml")
    |> app

  response.status
  |> should.equal(418)
}
