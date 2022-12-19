import todomvc/tests
import todomvc/item.{Item}
import todomvc/user
import todomvc/error
import gleeunit/should

pub fn item_creation_test() {
  use db <- tests.with_db
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
}

pub fn item_creation_without_content_test() {
  use db <- tests.with_db
  let user_id = user.insert_user(db)

  // Items cannot be added without content
  item.insert_item("", user_id, db)
  |> should.equal(Error(error.ContentRequired))

  item.list_items(user_id, db)
  |> should.equal([])
}

pub fn item_with_unknown_user_test() {
  use db <- tests.with_db
  // Items cannot be added for an unknown user
  item.insert_item("One", -1, db)
  |> should.equal(Error(error.UserNotFound))
}

pub fn toggle_test() {
  use db <- tests.with_db
  let user_id = user.insert_user(db)

  // Items can be added
  assert Ok(id1) = item.insert_item("One", user_id, db)

  item.toggle_completion(id1, user_id, db)
  |> should.equal(Ok(Item(id: id1, completed: True, content: "One")))
  item.toggle_completion(id1, user_id, db)
  |> should.equal(Ok(Item(id: id1, completed: False, content: "One")))
}

pub fn toggle_unknown_id_test() {
  use db <- tests.with_db
  let user_id = user.insert_user(db)

  item.toggle_completion(0, user_id, db)
  |> should.equal(Error(error.NotFound))
}

pub fn toggle_user_mismatch_test() {
  use db <- tests.with_db
  let user_id1 = user.insert_user(db)
  let user_id2 = user.insert_user(db)

  // Items can be added
  assert Ok(id1) = item.insert_item("One", user_id1, db)

  item.toggle_completion(id1, user_id2, db)
  |> should.equal(Error(error.NotFound))
}

pub fn counts_test() {
  use db <- tests.with_db
  let user_id1 = user.insert_user(db)
  let user_id2 = user.insert_user(db)

  item.get_counts(user_id1, db)
  |> should.equal(item.Counts(active: 0, completed: 0))

  assert Ok(id1) = item.insert_item("x", user_id1, db)
  assert Ok(id2) = item.insert_item("x", user_id1, db)
  assert Ok(id3) = item.insert_item("x", user_id1, db)
  assert Ok(_id) = item.insert_item("x", user_id1, db)
  assert Ok(_id) = item.insert_item("x", user_id2, db)
  assert Ok(_id) = item.insert_item("x", user_id2, db)

  item.get_counts(user_id1, db)
  |> should.equal(item.Counts(active: 4, completed: 0))

  assert Ok(_) = item.toggle_completion(id1, user_id1, db)
  assert Ok(_) = item.toggle_completion(id2, user_id1, db)
  assert Ok(_) = item.toggle_completion(id3, user_id1, db)

  item.get_counts(user_id1, db)
  |> should.equal(item.Counts(active: 1, completed: 3))
}

pub fn delete_test() {
  use db <- tests.with_db
  let user_id = user.insert_user(db)
  assert Ok(id) = item.insert_item("x", user_id, db)

  item.delete_item(id, user_id, db)
  |> should.equal(True)

  item.list_items(user_id, db)
  |> should.equal([])

  item.delete_item(id, user_id, db)
  |> should.equal(False)
}

pub fn delete_other_users_item_test() {
  use db <- tests.with_db
  let user_id1 = user.insert_user(db)
  let user_id2 = user.insert_user(db)
  assert Ok(id) = item.insert_item("x", user_id1, db)

  // It belongs to someone else so it can't be deleted
  item.delete_item(id, user_id2, db)
  |> should.equal(False)

  item.list_items(user_id1, db)
  |> should.equal([Item(id: id, completed: False, content: "x")])
}

pub fn delete_completed_test() {
  use db <- tests.with_db
  let user_id1 = user.insert_user(db)
  let user_id2 = user.insert_user(db)

  // Create a bunch of items for both users
  assert Ok(id1) = item.insert_item("x", user_id1, db)
  assert Ok(id2) = item.insert_item("x", user_id1, db)
  assert Ok(id3) = item.insert_item("x", user_id1, db)
  assert Ok(id4) = item.insert_item("x", user_id1, db)
  assert Ok(id5) = item.insert_item("x", user_id2, db)
  assert Ok(id6) = item.insert_item("x", user_id2, db)

  // Mark some items as completed for both users
  assert Ok(_) = item.toggle_completion(id1, user_id1, db)
  assert Ok(_) = item.toggle_completion(id2, user_id1, db)
  assert Ok(_) = item.toggle_completion(id6, user_id2, db)

  // Delete completed items for the first user
  item.delete_completed(user_id1, db)
  |> should.equal(2)

  // Completed items for that user have been deleted
  item.list_items(user_id1, db)
  |> should.equal([
    Item(id: id3, completed: False, content: "x"),
    Item(id: id4, completed: False, content: "x"),
  ])

  // The other user's items were not impacted
  item.list_items(user_id2, db)
  |> should.equal([
    Item(id: id5, completed: False, content: "x"),
    Item(id: id6, completed: True, content: "x"),
  ])
}
