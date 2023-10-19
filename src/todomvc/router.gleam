import gleam/http
import gleam/list
import gleam/string
import gleam/result
import todomvc/templates/home as home_template
import todomvc/templates/item as item_template
import todomvc/templates/item_created as item_created_template
import todomvc/templates/item_changed as item_changed_template
import todomvc/templates/item_deleted as item_deleted_template
import todomvc/templates/completed_cleared as completed_cleared_template
import todomvc/item.{Category, Item}
import todomvc/web.{Context}
import wisp.{Request, Response}
import gleam/io

pub fn handle_request(req: Request, ctx: Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use ctx <- web.authenticate(req, ctx)
  use <- wisp.serve_static(req, under: "/", from: ctx.static_path)

  io.debug(req)

  case wisp.path_segments(req) {
    [] -> home(ctx, item.All)
    ["active"] -> home(ctx, item.Active)
    ["completed"] -> completed(req, ctx)
    ["todos"] -> todos(req, ctx)
    ["todos", id] -> todo_item(req, ctx, id)
    ["todos", id, "completion"] -> item_completion(req, ctx, id)
    _ -> wisp.not_found()
  }
}

fn home(ctx: Context, category: Category) -> Response {
  let items = case category {
    item.All -> item.list_items(ctx.user_id, ctx.db)
    item.Active -> item.filtered_items(ctx.user_id, False, ctx.db)
    item.Completed -> item.filtered_items(ctx.user_id, True, ctx.db)
  }
  let counts = item.get_counts(ctx.user_id, ctx.db)

  home_template.render_builder(items, counts, category)
  |> wisp.html_response(200)
}

fn completed(request: Request, ctx: Context) -> Response {
  case request.method {
    http.Get -> home(ctx, item.Completed)
    http.Delete -> delete_completed(request, ctx)
    _ -> wisp.method_not_allowed([http.Get, http.Delete])
  }
}

fn delete_completed(request: Request, ctx: Context) -> Response {
  item.delete_completed(ctx.user_id, ctx.db)
  let counts = item.get_counts(ctx.user_id, ctx.db)
  let items = case current_category(request) {
    item.All | item.Active -> item.list_items(ctx.user_id, ctx.db)
    item.Completed -> []
  }

  completed_cleared_template.render_builder(items, counts)
  |> wisp.html_response(201)
}

fn todos(request: Request, ctx: Context) -> Response {
  case request.method {
    http.Post -> create_todo(request, ctx)
    _ -> wisp.method_not_allowed([http.Post])
  }
}

fn create_todo(request: Request, ctx: Context) -> Response {
  use params <- wisp.require_form(request)

  let result = {
    use content <- result.try(web.key_find(params.values, "content"))
    use id <- result.try(item.insert_item(content, ctx.user_id, ctx.db))
    Ok(Item(id: id, completed: False, content: content))
  }
  use item <- web.require_ok(result)

  let counts = item.get_counts(ctx.user_id, ctx.db)
  let display = item.is_member(item, current_category(request))

  item_created_template.render_builder(item, counts, display)
  |> wisp.html_response(201)
}

fn todo_item(request: Request, ctx: Context, id: String) -> Response {
  case request.method {
    http.Get -> get_todo_edit_form(ctx, id)
    http.Delete -> delete_item(ctx, id)
    http.Patch -> update_todo(request, ctx, id)
    _ -> wisp.method_not_allowed([http.Get, http.Delete, http.Patch])
  }
}

fn get_todo_edit_form(ctx: Context, id: String) -> Response {
  let result = {
    use id <- result.try(web.parse_int(id))
    item.get_item(id, ctx.user_id, ctx.db)
  }
  use item <- web.require_ok(result)

  item_template.render_builder(item, True)
  |> wisp.html_response(200)
}

fn update_todo(request: Request, ctx: Context, id: String) -> Response {
  use form <- wisp.require_form(request)
  let result = {
    use id <- result.try(web.parse_int(id))
    use content <- result.try(web.key_find(form.values, "content"))
    item.update_item(id, ctx.user_id, content, ctx.db)
  }
  use item <- web.require_ok(result)

  item_template.render_builder(item, True)
  |> wisp.html_response(200)
}

fn delete_item(ctx: Context, id: String) -> Response {
  use id <- web.require_ok(web.parse_int(id))
  item.delete_item(id, ctx.user_id, ctx.db)

  item.get_counts(ctx.user_id, ctx.db)
  |> item_deleted_template.render_builder
  |> wisp.html_response(200)
}

fn item_completion(request: Request, ctx: Context, id: String) -> Response {
  let result = {
    use id <- result.try(web.parse_int(id))
    item.toggle_completion(id, ctx.user_id, ctx.db)
  }
  use item <- web.require_ok(result)

  let counts = item.get_counts(ctx.user_id, ctx.db)
  let display = item.is_member(item, current_category(request))

  item_changed_template.render_builder(item, counts, display)
  |> wisp.html_response(200)
}

fn current_category(request: Request) -> Category {
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
