import gleam/string_builder.{StringBuilder}
import gleam/list
import gleam/int

pub fn render_builder(
  completed_count completed_count: Int,
  remaining_count remaining_count: Int,
  can_clear_completed can_clear_completed: Bool,
) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder =
    string_builder.append(
      builder,
      "

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
  completed_count completed_count: Int,
  remaining_count remaining_count: Int,
  can_clear_completed can_clear_completed: Bool,
) -> String {
  string_builder.to_string(render_builder(
    completed_count: completed_count,
    remaining_count: remaining_count,
    can_clear_completed: can_clear_completed,
  ))
}
