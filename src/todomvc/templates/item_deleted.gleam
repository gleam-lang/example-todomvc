import gleam/string_builder.{StringBuilder}
import gleam/list
import todomvc/item.{Counts}
import gleam/int

pub fn render_builder(counts counts: Counts) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder =
    string_builder.append(
      builder,
      "

<div hx-swap-oob=\"innerHTML\" id=\"clear-completed\">
  ",
    )
  let builder = case item.any_completed(counts) {
    True -> {
      let builder = string_builder.append(builder, "
  Clear Completed (")
      let builder =
        string_builder.append(builder, int.to_string(counts.completed))
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
  let builder = string_builder.append(builder, int.to_string(counts.active))
  let builder = string_builder.append(builder, "</strong> todos left
</span>
")

  builder
}

pub fn render(counts counts: Counts) -> String {
  string_builder.to_string(render_builder(counts: counts))
}
