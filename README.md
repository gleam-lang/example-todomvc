# todomvc

A backend based implementation of [TodoMVC][todomvc] and an example Gleam
project.

[todomvc]: https://todomvc.com/

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
