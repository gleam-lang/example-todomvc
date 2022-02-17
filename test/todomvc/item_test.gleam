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

pub fn toggle_test() {
  tests.with_db(fn(db) {
    let user_id = user.insert_user(db)

    // Items can be added
    assert Ok(id1) = item.insert_item("One", user_id, db)

    item.toggle_completion(id1, user_id, db)
    |> should.equal(Ok(True))
    item.toggle_completion(id1, user_id, db)
    |> should.equal(Ok(False))
  })
}

pub fn toggle_unknown_id_test() {
  tests.with_db(fn(db) {
    let user_id = user.insert_user(db)

    item.toggle_completion(0, user_id, db)
    |> should.equal(Error(Nil))
  })
}

pub fn toggle_user_mismatch_test() {
  tests.with_db(fn(db) {
    let user_id1 = user.insert_user(db)
    let user_id2 = user.insert_user(db)

    // Items can be added
    assert Ok(id1) = item.insert_item("One", user_id1, db)

    item.toggle_completion(id1, user_id2, db)
    |> should.equal(Error(Nil))
  })
}

pub fn counts_test() {
  tests.with_db(fn(db) {
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
  })
}

pub fn delete_test() {
  tests.with_db(fn(db) {
    let user_id = user.insert_user(db)
    assert Ok(id) = item.insert_item("x", user_id, db)

    item.delete_item(id, user_id, db)
    |> should.equal(True)

    item.list_items(user_id, db)
    |> should.equal([])

    item.delete_item(id, user_id, db)
    |> should.equal(False)
  })
}

pub fn delete_other_users_item_test() {
  tests.with_db(fn(db) {
    let user_id1 = user.insert_user(db)
    let user_id2 = user.insert_user(db)
    assert Ok(id) = item.insert_item("x", user_id1, db)

    item.delete_item(id, user_id2, db)
    |> should.equal(False)

    item.list_items(user_id1, db)
    |> should.equal([Item(id: id, completed: False, content: "x")])
  })
}
