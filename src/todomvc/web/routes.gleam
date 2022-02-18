import gleam/bit_builder.{BitBuilder}
import gleam/http/service.{Service}
import gleam/http/request.{Request}
import gleam/http/response
import gleam/http
import gleam/uri
import gleam/list
import gleam/result
import gleam/function
import gleam/bit_string
import gleam/string_builder.{StringBuilder}
import gleam/pgo
import todomvc/templates/home as home_template
import todomvc/templates/item as item_template
import todomvc/templates/item_created as item_created_template
import todomvc/templates/item_changed as item_changed_template
import todomvc/templates/item_deleted as item_deleted_template
import todomvc/templates/completed_cleared as completed_cleared_template
import todomvc/item.{Item}
import todomvc/error
import todomvc/item.{Category}
import todomvc/web
import todomvc/web/static
import todomvc/web/print_requests
import gleam/io

pub fn router(request: web.AppRequest) -> web.AppResult {
  case request.path {
    [] -> home(request, item.All)
    ["active"] -> home(request, item.Active)
    ["completed"] -> completed(request)
    ["todos"] -> todos(request)
    ["todos", id] -> todo_item(request, id)
    ["todos", id, "completion"] -> item_completion(request, id)
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

fn home(request: web.AppRequest, category: Category) -> web.AppResult {
  let items = case category {
    item.All -> item.list_items(request.user_id, request.db)
    item.Active -> item.filtered_items(request.user_id, False, request.db)
    item.Completed -> item.filtered_items(request.user_id, True, request.db)
  }
  let counts = item.get_counts(request.user_id, request.db)

  home_template.render_builder(items, counts, category)
  |> web.html_response(200)
  |> Ok
}

fn completed(request: web.AppRequest) -> web.AppResult {
  case request.method {
    http.Get -> home(request, item.Completed)
    http.Delete -> delete_completed(request)
    _ -> Error(error.MethodNotAllowed)
  }
}

// TODO: handle that we may be on the completed page or something
fn delete_completed(request: web.AppRequest) -> web.AppResult {
  item.delete_completed(request.user_id, request.db)
  let items = item.list_items(request.user_id, request.db)
  let counts = item.get_counts(request.user_id, request.db)

  completed_cleared_template.render_builder(items, counts)
  |> web.html_response(201)
  |> Ok
}

fn todos(request: web.AppRequest) -> web.AppResult {
  case request.method {
    http.Post -> create_todo(request)
    _ -> Error(error.MethodNotAllowed)
  }
}

fn create_todo(request: web.AppRequest) -> web.AppResult {
  try params = web.parse_urlencoded_body(request)
  try content = web.key_find(params, "content")
  try id = item.insert_item(content, request.user_id, request.db)
  let item = Item(id: id, completed: False, content: content)
  let counts = item.get_counts(request.user_id, request.db)

  item_created_template.render_builder(item: item, counts: counts)
  |> web.html_response(201)
  |> Ok
}

fn todo_item(request: web.AppRequest, id: String) -> web.AppResult {
  case request.method {
    http.Get -> get_todo_edit_form(request, id)
    http.Delete -> delete_item(request, id)
    http.Patch -> update_todo(request, id)
    _ -> Error(error.MethodNotAllowed)
  }
}

fn get_todo_edit_form(request: web.AppRequest, id: String) -> web.AppResult {
  try id = web.parse_int(id)
  try item = item.get_item(id, request.user_id, request.db)
  item_template.render_builder(item, True)
  |> web.html_response(200)
  |> Ok
}

fn update_todo(request: web.AppRequest, id: String) -> web.AppResult {
  try id = web.parse_int(id)
  try params = web.parse_urlencoded_body(request)
  try content = web.key_find(params, "content")
  try item = item.update_item(id, request.user_id, content, request.db)

  item_template.render_builder(item, False)
  |> web.html_response(200)
  |> Ok
}

fn delete_item(request: web.AppRequest, id: String) -> web.AppResult {
  try id = web.parse_int(id)
  item.delete_item(id, request.user_id, request.db)

  item.get_counts(request.user_id, request.db)
  |> item_deleted_template.render_builder
  |> web.html_response(200)
  |> Ok
}

fn item_completion(request: web.AppRequest, id: String) -> web.AppResult {
  try id = web.parse_int(id)
  try item = item.toggle_completion(id, request.user_id, request.db)
  let counts = item.get_counts(request.user_id, request.db)

  item_changed_template.render_builder(item, counts)
  |> web.html_response(200)
  |> Ok
}
