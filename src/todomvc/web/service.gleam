import gleam/bit_builder.{BitBuilder}
import gleam/http/service.{Service}
import gleam/http/request.{Request}
import gleam/http/response
import gleam/function
import todomvc/web/templates/home as home_template
import todomvc/item.{Item}
import todomvc/web
import todomvc/web/static
import todomvc/web/logger

pub fn router(request: Request(BitString)) -> web.Result {
  case request.path_segments(request) {
    [] -> home()
    _ -> Error(web.NotFound)
  }
}

pub fn stack() -> Service(BitString, BitBuilder) {
  router
  |> function.compose(web.result_to_response)
  |> service.prepend_response_header("made-with", "Gleam")
  |> service.map_response_body(bit_builder.from_string_builder)
  |> logger.middleware
  |> static.middleware()
}

fn home() -> web.Result {
  let items = [
    Item(id: 1, completed: True, content: "Create Gleam"),
    Item(id: 2, completed: False, content: "Write TodoMVC in Gleam"),
    Item(id: 3, completed: False, content: "Deploy TodoMVC"),
    Item(id: 4, completed: False, content: "<script>alert(1)</script>"),
  ]

  home_template.render_builder(items)
  |> web.html_response(200)
  |> Ok
}
