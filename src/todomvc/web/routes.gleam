import gleam/bit_builder.{BitBuilder}
import gleam/http/service.{Service}
import gleam/http/request.{Request}
import gleam/http/response
import gleam/http
import gleam/function
import gleam/bit_string
import gleam/string_builder.{StringBuilder}
import gleam/pgo
import todomvc/templates/home as home_template
import todomvc/templates/item_created as item_created_template
import todomvc/templates/item_deleted as item_deleted_template
import todomvc/item.{Item}
import todomvc/error
import todomvc/web
import todomvc/web/static
import todomvc/web/print_requests

pub fn router(request: web.AppRequest) -> web.AppResult {
  case request.path {
    [] -> home(request, All)
    ["active"] -> home(request, Active)
    ["completed"] -> completed(request)
    ["todos"] -> todos(request)
    ["todos", id] -> todo_item(request, id)
    _ -> Error(error.NotFound)
  }
}

pub fn stack(
  secret: String,
  db: pgo.Connection,
) -> Service(BitString, BitBuilder) {
  router
  |> web.authenticate(secret, db)
  |> function.compose(web.result_to_response)
  |> string_body_middleware
  |> service.map_response_body(bit_builder.from_string_builder)
  |> print_requests.middleware
  |> static.middleware()
  |> service.prepend_response_header("made-with", "Gleam")
}

pub fn string_body_middleware(
  service: Service(String, StringBuilder),
) -> Service(BitString, StringBuilder) {
  fn(request: Request(BitString)) {
    case bit_string.to_string(request.body) {
      Ok(body) -> service(request.set_body(request, body))
      Error(_) -> web.bad_request()
    }
  }
}

pub type ItemsCategory {
  All
  Active
  Completed
}

fn home(request: web.AppRequest, _category: ItemsCategory) -> web.AppResult {
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

fn completed(request: web.AppRequest) -> web.AppResult {
  case request.method {
    http.Get -> home(request, Completed)
    http.Delete -> todo
    _ -> Error(error.MethodNotAllowed)
  }
}

fn todos(request: web.AppRequest) -> web.AppResult {
  case request.method {
    http.Post -> create_todo(request)
    _ -> Error(error.MethodNotAllowed)
  }
}

fn create_todo(_request: web.AppRequest) -> web.AppResult {
  // TODO: create item
  let item = Item(id: 5, completed: False, content: "wibble")
  item_created_template.render_builder(
    item: item,
    // TODO: count
    completed_count: 5,
    // TODO: count
    remaining_count: 10,
    // TODO: count
    can_clear_completed: True,
  )
  |> web.html_response(201)
  |> Ok
}

fn todo_item(request: web.AppRequest, id: String) -> web.AppResult {
  case request.method {
    http.Get -> todo
    http.Delete -> delete_item(request, id)
    http.Put -> todo
    _ -> Error(error.MethodNotAllowed)
  }
}

fn delete_item(request: web.AppRequest, _id: String) -> web.AppResult {
  // TODO: delete item
  item_deleted_template.render_builder(
    // TODO: count
    completed_count: 4,
    // TODO: count
    remaining_count: 9,
    // TODO: count
    can_clear_completed: True,
  )
  |> web.html_response(200)
  |> Ok
}
