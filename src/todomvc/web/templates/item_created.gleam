import gleam/string_builder.{StringBuilder}
import gleam/list
import todomvc/web/templates/item as item_template
import todomvc/item.{Item}
import gleam/int

pub fn render_builder(
  item item: Item,
  completed_count completed_count: Int,
  remaining_count remaining_count: Int,
  can_clear_completed can_clear_completed: Bool,
) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder =
    string_builder.append(
      builder,
      "

<input
  autofocus 
  required 
  class=\"new-todo\"
  placeholder=\"What needs to be complete?\"
  name=\"content\"
  autocomplete=\"off\"
>

<div hx-swap-oob=\"afterbegin\" id=\"todo-list\">
  ",
    )
  let builder =
    string_builder.append_builder(builder, item_template.render_builder(item))
  let builder =
    string_builder.append(
      builder,
      "
</div>

<div hx-swap-oob=\"innerHTML\" id=\"clear-completed\">
  ",
    )
  let builder = case can_clear_completed {
    True -> {
      let builder = string_builder.append(builder, "
  Clear Completed (")
      let builder =
        string_builder.append(builder, int.to_string(completed_count))
      let builder = string_builder.append(builder, ")
  ")
      builder
    }
    False -> builder
  }
  let builder =
    string_builder.append(
      builder,
      "
</div>

<span hx-swap-oob=\"innerHTML\" id=\"todo-count\">
  <strong>",
    )
  let builder = string_builder.append(builder, int.to_string(remaining_count))
  let builder = string_builder.append(builder, "</strong> todos left
</span>
")

  builder
}

pub fn render(
  item item: Item,
  completed_count completed_count: Int,
  remaining_count remaining_count: Int,
  can_clear_completed can_clear_completed: Bool,
) -> String {
  string_builder.to_string(render_builder(
    item: item,
    completed_count: completed_count,
    remaining_count: remaining_count,
    can_clear_completed: can_clear_completed,
  ))
}
