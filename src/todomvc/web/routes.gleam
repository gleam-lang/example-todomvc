import gleam/bit_builder.{BitBuilder}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/http
import gleam/list
import gleam/string
import gleam/result
import gleam/bit_string
import gleam/string_builder.{StringBuilder}
import todomvc/templates/home as home_template
import todomvc/templates/item as item_template
import todomvc/templates/item_created as item_created_template
import todomvc/templates/item_changed as item_changed_template
import todomvc/templates/item_deleted as item_deleted_template
import todomvc/templates/completed_cleared as completed_cleared_template
import todomvc/item.{Category, Item}
import todomvc/database
import todomvc/web
import todomvc/web/static
import todomvc/web/log_requests

pub fn router(request: web.AppRequest) -> Response(StringBuilder) {
  case request.path {
    [] -> home(request, item.All)
    ["active"] -> home(request, item.Active)
    ["completed"] -> completed(request)
    ["todos"] -> todos(request)
    ["todos", id] -> todo_item(request, id)
    ["todos", id, "completion"] -> item_completion(request, id)
    _ -> web.not_found()
  }
}

pub fn app(
  request: Request(BitString),
  secret: String,
  db: String,
) -> Response(BitBuilder) {
  use <- static.middleware(request)
  use <- log_requests.middleware(request)
  use request <- convert_string_body(request)
  use request <- web.authenticate(request, secret, db)
  router(request)
}

pub fn convert_string_body(
  request: Request(BitString),
  next: fn(Request(String)) -> Response(StringBuilder),
) -> Response(BitBuilder) {
  case bit_string.to_string(request.body) {
    Ok(body) ->
      request
      |> request.set_body(body)
      |> next
    Error(_) -> web.bad_request()
  }
  |> response.map(bit_builder.from_string_builder)
}

fn home(request: web.AppRequest, category: Category) -> Response(StringBuilder) {
  use db <- database.with_connection(request.db)
  let items = case category {
    item.All -> item.list_items(request.user_id, db)
    item.Active -> item.filtered_items(request.user_id, False, db)
    item.Completed -> item.filtered_items(request.user_id, True, db)
  }
  let counts = item.get_counts(request.user_id, db)

  home_template.render_builder(items, counts, category)
  |> web.html_response(200)
}

fn completed(request: web.AppRequest) -> Response(StringBuilder) {
  case request.method {
    http.Get -> home(request, item.Completed)
    http.Delete -> delete_completed(request)
    _ -> web.method_not_allowed()
  }
}

fn delete_completed(request: web.AppRequest) -> Response(StringBuilder) {
  use db <- database.with_connection(request.db)
  item.delete_completed(request.user_id, db)
  let counts = item.get_counts(request.user_id, db)
  let items = case current_category(request) {
    item.All | item.Active -> item.list_items(request.user_id, db)
    item.Completed -> []
  }

  completed_cleared_template.render_builder(items, counts)
  |> web.html_response(201)
}

fn todos(request: web.AppRequest) -> Response(StringBuilder) {
  case request.method {
    http.Post -> create_todo(request)
    _ -> web.method_not_allowed()
  }
}

fn create_todo(request: web.AppRequest) -> Response(StringBuilder) {
  use params <- web.try_(web.parse_urlencoded_body(request))
  use content <- web.try_(web.key_find(params, "content"))
  use db <- database.with_connection(request.db)
  use id <- web.try_(item.insert_item(content, request.user_id, db))
  let item = Item(id: id, completed: False, content: content)
  let counts = item.get_counts(request.user_id, db)
  let display = item.is_member(item, current_category(request))

  item_created_template.render_builder(item, counts, display)
  |> web.html_response(201)
}

fn todo_item(request: web.AppRequest, id: String) -> Response(StringBuilder) {
  case request.method {
    http.Get -> get_todo_edit_form(request, id)
    http.Delete -> delete_item(request, id)
    http.Patch -> update_todo(request, id)
    _ -> web.method_not_allowed()
  }
}

fn get_todo_edit_form(
  request: web.AppRequest,
  id: String,
) -> Response(StringBuilder) {
  use id <- web.try_(web.parse_int(id))
  use db <- database.with_connection(request.db)
  use item <- web.try_(item.get_item(id, request.user_id, db))
  item_template.render_builder(item, True)
  |> web.html_response(200)
}

fn update_todo(request: web.AppRequest, id: String) -> Response(StringBuilder) {
  use id <- web.try_(web.parse_int(id))
  use params <- web.try_(web.parse_urlencoded_body(request))
  use content <- web.try_(web.key_find(params, "content"))
  use db <- database.with_connection(request.db)
  use item <- web.try_(item.update_item(id, request.user_id, content, db))

  item_template.render_builder(item, False)
  |> web.html_response(200)
}

fn delete_item(request: web.AppRequest, id: String) -> Response(StringBuilder) {
  use id <- web.try_(web.parse_int(id))
  use db <- database.with_connection(request.db)
  item.delete_item(id, request.user_id, db)

  item.get_counts(request.user_id, db)
  |> item_deleted_template.render_builder
  |> web.html_response(200)
}

fn item_completion(
  request: web.AppRequest,
  id: String,
) -> Response(StringBuilder) {
  use id <- web.try_(web.parse_int(id))
  use db <- database.with_connection(request.db)
  use item <- web.try_(item.toggle_completion(id, request.user_id, db))
  let counts = item.get_counts(request.user_id, db)
  let display = item.is_member(item, current_category(request))

  item_changed_template.render_builder(item, counts, display)
  |> web.html_response(200)
}

fn current_category(request: web.AppRequest) -> Category {
  let current_url =
    request.headers
    |> list.key_find("hx-current-url")
    |> result.unwrap("")
  case string.contains(current_url, "/active") {
    True -> item.Active
    False ->
      case string.contains(current_url, "/completed") {
        True -> item.Completed
        False -> item.All
      }
  }
}
