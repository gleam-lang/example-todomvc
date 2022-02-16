import gleam/string_builder.{StringBuilder}
import gleam/list
import todomvc/item.{Item}
import todomvc/web
import gleam/int

pub fn render_builder(item item: Item) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder = string_builder.append(builder, "

<li 
  id=\"item-")
  let builder = string_builder.append(builder, int.to_string(item.id))
  let builder = string_builder.append(builder, "\"
  ")
  let builder = case item.completed {
    True -> {
      let builder = string_builder.append(builder, "class=\"completed\"")
      builder
    }
    False -> builder
  }
  let builder =
    string_builder.append(
      builder,
      "
>
  <div class=\"view\">
    <!-- TODO: edit -->
    <input class=\"toggle\" type=\"checkbox\" ",
    )
  let builder = case item.completed {
    True -> {
      let builder = string_builder.append(builder, "checked")
      builder
    }
    False -> builder
  }
  let builder = string_builder.append(builder, ">

    <label>
      ")
  let builder = string_builder.append(builder, web.escape(item.content))
  let builder =
    string_builder.append(builder, "
    </label>

    <a href=\"/todos/")
  let builder = string_builder.append(builder, int.to_string(item.id))
  let builder =
    string_builder.append(
      builder,
      "\" class=\"edit-btn\">✎</a>

    <!-- TODO: delete -->
    <button
      class=\"destroy\"
      hx-delete=\"/todos/",
    )
  let builder = string_builder.append(builder, int.to_string(item.id))
  let builder = string_builder.append(builder, "\"
      hx-target=\"#item-")
  let builder = string_builder.append(builder, int.to_string(item.id))
  let builder =
    string_builder.append(
      builder,
      "\"
    ></button>
    </form>

    <!-- TODO: toggle completion -->
    <form class=\"todo-mark\" method=\"post\" action=\"/todo/",
    )
  let builder = string_builder.append(builder, int.to_string(item.id))
  let builder =
    string_builder.append(
      builder,
      "\">
      <button></button>
    </form>
  </div>
",
    )

  builder
}

pub fn render(item item: Item) -> String {
  string_builder.to_string(render_builder(item: item))
}
