import todomvc/tests
import todomvc/item.{Item}
import todomvc/user
import todomvc/error
import gleeunit/should

pub fn item_creation_test() {
  tests.with_db(fn(db) {
    let user_id = user.insert_user(db)

    // A user starts with no items
    item.list_items(user_id, db)
    |> should.equal([])

    // Items can be added
    assert Ok(id1) = item.insert_item("One", user_id, db)
    assert Ok(id2) = item.insert_item("Two", user_id, db)

    item.list_items(user_id, db)
    |> should.equal([
      Item(id: id1, content: "One", completed: False),
      Item(id: id2, content: "Two", completed: False),
    ])
  })
}

pub fn item_with_unknown_user_test() {
  tests.with_db(fn(db) {
    // Items cannot be added for an unknown user
    item.insert_item("One", -1, db)
    |> should.equal(Error(error.UserNotFound))
  })
}
