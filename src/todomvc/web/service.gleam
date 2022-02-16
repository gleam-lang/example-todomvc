import gleam/bit_builder.{BitBuilder}
import gleam/http/service.{Service}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import todomvc/web/templates/home as home_template
import todomvc/item.{Item}
import todomvc/web
import todomvc/web/static
import todomvc/web/logger

pub fn stack() -> Service(BitString, BitBuilder) {
  router
  |> service.prepend_response_header("made-with", "Gleam")
  |> logger.middleware
  |> static.middleware()
}

fn router(request: Request(BitString)) -> Response(BitBuilder) {
  case request.path_segments(request) {
    [] -> home()
    _ -> web.not_found()
  }
}

fn home() {
  let items = [
    Item(id: 1, completed: True, content: "Create Gleam"),
    Item(id: 2, completed: False, content: "Write TodoMVC in Gleam"),
    Item(id: 3, completed: False, content: "Deploy TodoMVC"),
    Item(id: 4, completed: False, content: "<script>alert(1)</script>"),
  ]
  let html = home_template.render_builder(items)

  response.new(200)
  |> response.set_body(html)
  |> response.map(bit_builder.from_string_builder)
}
