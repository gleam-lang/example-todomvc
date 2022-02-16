import gleam/string_builder.{StringBuilder}
import gleam/list
import todomvc/web/templates/item as item_template
import todomvc/item.{Item}
import gleam/result
import gleam/list

pub fn render_builder(items items: List(Item)) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder =
    string_builder.append(
      builder,
      "

<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\">
  <link rel=\"shortcut icon\" href=\"/assets/favicon.ico\" type=\"image/x-icon\">
  <link rel=\"icon\" href=\"/assets/favicon.ico\" type=\"image/x-icon\">
  <link rel=\"stylesheet\" href=\"/assets/main.css\">
  <script src=\"/vendor/htmx.min.js\"></script>
  <title>TodoMVC in Gleam</title>
</head>
<body class=\"learn-bar\">
  <aside class=\"learn\">
    <header>
      <img id=\"logo\" src=\"/assets/gleam-logo.jpg\" alt=\"Gleam Logo\">
      <h3>Gleam</h3>
      <span>
        <h5>Example</h5>
      </span>
      <a href=\"https://github.com/gleam-lang/example-todomvc\">Source</a>
    </header>
    <hr>

    <blockquote class=\"quote speech-bubble\">
      <p>Gleam is a friendly language for building type-safe, scalable systems! ✨</p>
      <footer><a href=\"https://gleam.run\">Gleam</a></footer>
    </blockquote>
    <hr>

    <h4>Official Resources</h4>
    <ul>
      <li><a href=\"https://gleam.run\">Gleam Homepage</a></li>
      <li><a href=\"https://github.com/gleam-lang\">Gleam on GitHub</a></li>
    </ul>

    <h4>Community</h4>
    <ul>
      <li><a href=\"https://discord.gg/Fm8Pwmy\">Gleam Discord Server</a></li>
    </ul>
  </aside>

  <div class=\"todomvc-wrapper\">
    <section class=\"todoapp\">
      <header class=\"header\">
        <h1>todos</h1>
        <!-- TODO: creation -->
        <form hx-post=\"/todos\">
          <input
            autofocus
            required
            class=\"new-todo\"
            placeholder=\"What needs to be complete?\"
            name=\"content\"
            autocomplete=\"off\"
          >
        </form>
      </header>

      <section class=\"main\">
        <ul id=\"todo-list\" class=\"todo-list\">
          ",
    )
  let builder =
    list.fold(
      items,
      builder,
      fn(builder, item: Item) {
        let builder = string_builder.append(builder, "
          ")
        let builder =
          string_builder.append_builder(
            builder,
            item_template.render_builder(item),
          )
        let builder = string_builder.append(builder, "
          ")

        builder
      },
    )
  let builder =
    string_builder.append(
      builder,
      "
        </ul>
      </section>

      <!-- TODO: filters -->
      <footer class=\"footer\">
        <!-- TODO: count -->
        <span id=\"todo-count\" class=\"todo-count\">
          <strong>0</strong> todos left
        </span>
        <ul class=\"filters\">
          <!-- TODO: highlight selected -->
          <!-- TODO: set selected depending on which page we're on -->
          <li><a class=\"\" href=\"/\">All</a></li>
          <li><a class=\"\" href=\"/active\">Active</a></li>
          <li><a class=\"selected\" href=\"/completed\">Completed</a></li>
        </ul>

        <!-- TODO: clear -->
        <!-- TODO: counter -->
        <button id=\"clear-completed\" class=\"clear-completed\">Clear Completed (1)</button>
      </footer>
    </section>

    <footer class=\"info\">
      <p>
        Inspired by <a href=\"https://todomvc.com/\">TodoMVC</a> and
        <a href=\"https://gitlab.com/greggreg/gleam_todo\">GregGreg's original
        Gleam implementation</a>
      </p>
    </footer>
  </div>
</body>
</html>
",
    )

  builder
}

pub fn render(items items: List(Item)) -> String {
  string_builder.to_string(render_builder(items: items))
}
