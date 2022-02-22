# TodoMVC

An example codebase that shows how to create a web application in Gleam. It is a
backend based implementation of [TodoMVC](https://todomvc.com/) and demonstrates
these features:

- A HTTP server
- Routing
- CRUD
- Use of a PostgreSQL database
- HTML templates
- Form parsing
- Signed cookie based authentication
- Serving static assets
- Logging
- Testing

Rather than demonstrate any particular frontend web framework this project uses
[HTMX](https://htmx.org/), a library that adds some new HTML attributes for
declaratively performing AJAX requests.

## Usage

You will need to have PostgreSQL installed with the user `postgres` with the
password `postgres`.

```sh
bin/reset_dev_database.sh

gleam run   # Run the web app
gleam test  # Run the tests
```

## HTML templates

The HTML templates are compiled using [gleam-templates](https://github.com/michaeljones/gleam-templates).

To regenerate the Gleam code from the templates run:

```shell
templates && gleam format .
```

## Thanks

Special thanks to [GregGreg](https://gitlab.com/greggreg/gleam_todo) for the
first version of TodoMVC in Gleam.
