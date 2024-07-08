import todomvc/tests
import todomvc/user

pub fn user_insertion_test() {
  use db <- tests.with_db("")
  user.insert_user(db)
}
