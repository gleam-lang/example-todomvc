# TodoMVC

An example codebase that shows how to create a web application in Gleam. It is a
backend based implementation of [TodoMVC](https://todomvc.com/) and demonstrates
these features:

- A HTTP server
- Routing
- CRUD
- Use of a SQLite database
- HTML templates
- Form parsing
- Signed cookie based authentication
- Serving static assets
- Logging
- Testing

Rather than demonstrate any particular frontend web framework this project uses
[HTMX](https://htmx.org/), a library that adds some new HTML attributes for
declaratively performing AJAX requests.

## HTML templates

The HTML templates are compiled using [matcha](https://github.com/michaeljones/matcha).

To regenerate the Gleam code from the templates run:

```shell
matcha && gleam format .
```

## Thanks

Special thanks to [GregGreg](https://gitlab.com/greggreg/gleam_todo) for the
first version of TodoMVC in Gleam.
