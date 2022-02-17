import gleam/io
import gleam/pgo
import todomvc/user
import todomvc/tests

pub fn user_creation_test() {
  tests.with_db(user.create_user)
}
