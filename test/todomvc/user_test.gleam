import todomvc/user
import todomvc/tests

pub fn user_insertion_test() {
  use db <- tests.with_db
  user.insert_user(db)
}
