import gleam/string_builder.{StringBuilder}
import gleam/list

import todomvc/item.{Item}

pub fn render_builder(items items: List(Item)) -> StringBuilder {
    let builder = string_builder.from_string("")
    let builder = string_builder.append(builder, "
<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\">
  <link rel=\"shortcut icon\" href=\"/assets/favicon.ico\" type=\"image/x-icon\">
  <link rel=\"icon\" href=\"/assets/favicon.ico\" type=\"image/x-icon\">
  <link rel=\"stylesheet\" href=\"/assets/main.css\">
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
      <!-- TODO: Information on Gleam -->
      <p>Something here about the type of language gleam is</p>
      <footer><a href=\"https://gleam.run\">Gleam</a></footer>
    </blockquote>
    <hr>

    <h4>Official Resources</h4>
    <ul>
      <li><a href=\"https://gleam.run\">Gleam Homepage</a></li>
      <li><a href=\"https://github.com/gleam-lang\">Gleam on GitHub</a></li>
    </ul>
    <hr>

  </aside>
  <div class=\"todomvc-wrapper\">
    <section class=\"todoapp\">
      <header class=\"header\">
        <h1>todos</h1>
        <!-- TODO: creation -->
        <form method=\"post\" action=\"/create\"><input autofocus=\"\" class=\"new-todo\" placeholder=\"What needs to be complete?\" name=\"newTodo\" autocomplete=\"off\"></form>
      </header>
      <section class=\"main\">
        <ul class=\"todo-list\">
          ")
    let builder = list.fold(items, builder, fn(builder, item) {
            let builder = string_builder.append(builder, "
          <li class=\"completed\">
            <div class=\"view\">
              <!-- TODO: edit -->
              <input class=\"toggle\" type=\"checkbox\" checked=\"\"><label>
                The text goes here
              </label><a href=\"/edit/08680FDA-9B22-4ADE-8E9B-23F54178A89E\" class=\"edit-btn\">✎</a>
              <!-- TODO: delete -->
              <form method=\"post\" action=\"/delete/08680FDA-9B22-4ADE-8E9B-23F54178A89E\"><button class=\"destroy\"></button></form>
              <!-- TODO: toggle completion -->
              <form class=\"todo-mark\" method=\"post\" action=\"/mark/active/08680FDA-9B22-4ADE-8E9B-23F54178A89E\"><button></button></form>
            </div>
          ")

        builder
})
    let builder = string_builder.append(builder, "
        </ul>
      </section>
      <!-- TODO: filters -->
      <footer class=\"footer\">
        <!-- TODO: count -->
        <span class=\"todo-count\"><strong>0</strong> todos left</span>
        <ul class=\"filters\">
          <!-- TODO: highlight selected -->
          <li><a class=\"\" href=\"/\">All</a></li>
          <li><a class=\"\" href=\"/active\">Active</a></li>
          <li><a class=\"selected\" href=\"/complete\">Completed</a></li>
        </ul>
        <!-- TODO: clear -->
        <!-- TODO: counter -->
        <form action=\"/clear-completed\" method=\"post\"><button class=\"clear-completed\">Clear Completed (1)</button></form>
      </footer>
    </section>
    <footer class=\"info\">
      <p>
        Inspired by <a href=\"https://gitlab.com/greggreg/gleam_todo\">GregGreg</a> and
        <a href=\"https://todomvc.com/\">TodoMVC</a>
      </p>
    </footer>
  </div>
</body>
</html>
")

    builder
}

pub fn render(items items: List(Item)) -> String {
    string_builder.to_string(render_builder(items: items))
}
