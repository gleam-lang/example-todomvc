import sqlight
import gleam/list
import gleam/bool
import gleam/result
import gleam/dynamic
import todomvc/error.{type AppError}

pub type Item {
  Item(id: Int, completed: Bool, content: String)
}

pub type Category {
  All
  Active
  Completed
}

pub type Counts {
  Counts(completed: Int, active: Int)
}

/// Decode an item from a database row.
///
pub fn item_row_decoder() -> dynamic.Decoder(Item) {
  dynamic.decode3(
    Item,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, sqlight.decode_bool),
    dynamic.element(2, dynamic.string),
  )
}

/// Count the number of completed and active items in the database for a user.
///
pub fn get_counts(user_id: Int, db: sqlight.Connection) -> Counts {
  let sql =
    "
select 
  completed,
  count(*)
from
  items
where
  items.user_id = ?1
group by
  completed
order by
  completed asc
"
  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(user_id)],
      expecting: dynamic.tuple2(sqlight.decode_bool, dynamic.int),
    )
  let completed =
    rows
    |> list.key_find(True)
    |> result.unwrap(0)
  let active =
    rows
    |> list.key_find(False)
    |> result.unwrap(0)
  Counts(active: active, completed: completed)
}

/// Insert a new item for a given user.
///
pub fn insert_item(
  content: String,
  user_id: Int,
  db: sqlight.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
insert into items
  (content, user_id) 
values 
  (?1, ?2)
returning
  id
"
  use rows <- result.then(
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.text(content), sqlight.int(user_id)],
      expecting: dynamic.element(0, dynamic.int),
    )
    |> result.map_error(fn(error) {
      case error.code, error.message {
        sqlight.ConstraintCheck, "CHECK constraint failed: empty_content" ->
          error.ContentRequired
        sqlight.ConstraintForeignkey, _ -> error.UserNotFound
        _, _ -> error.BadRequest
      }
    }),
  )

  let assert [id] = rows
  Ok(id)
}

/// Get a specific item for a user.
///
pub fn get_item(
  item_id: Int,
  user_id: Int,
  db: sqlight.Connection,
) -> Result(Item, AppError) {
  let sql =
    "
select
  id,
  completed,
  content
from
  items
where
  id = ?1
and
  user_id = ?2
"

  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(item_id), sqlight.int(user_id)],
      expecting: item_row_decoder(),
    )

  case rows {
    [item] -> Ok(item)
    _ -> Error(error.NotFound)
  }
}

/// List all the items for a user that have a particular completion state.
///
pub fn filtered_items(
  user_id: Int,
  completed: Bool,
  db: sqlight.Connection,
) -> List(Item) {
  let sql =
    "
select
  id,
  completed,
  content
from
  items
where
  user_id = ?1
and
  completed = ?2
order by
  inserted_at asc
"

  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(user_id), sqlight.bool(completed)],
      expecting: item_row_decoder(),
    )

  rows
}

/// List all the items for a user.
///
pub fn list_items(user_id: Int, db: sqlight.Connection) -> List(Item) {
  let sql =
    "
select
  id,
  completed,
  content
from
  items
where
  user_id = ?1
order by
  inserted_at asc
"

  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(user_id)],
      expecting: item_row_decoder(),
    )

  rows
}

/// Delete a specific item belonging to a user.
///
pub fn delete_item(item_id: Int, user_id: Int, db: sqlight.Connection) -> Nil {
  let sql =
    "
delete from
  items
where
  id = ?1
and
  user_id = ?2
"
  let assert Ok(_) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(item_id), sqlight.int(user_id)],
      expecting: Ok,
    )
  Nil
}

/// Update the content of a specific item belonging to a user.
///
pub fn update_item(
  item_id: Int,
  user_id: Int,
  content: String,
  db: sqlight.Connection,
) -> Result(Item, AppError) {
  let sql =
    "
update
  items
set
  content = ?3
where
  id = ?1
and
  user_id = ?2
returning
  id,
  completed,
  content
"
  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(item_id), sqlight.int(user_id), sqlight.text(content)],
      expecting: item_row_decoder(),
    )
  case rows {
    [item] -> Ok(item)
    _ -> Error(error.NotFound)
  }
}

/// Delete a specific item belonging to a user.
///
pub fn delete_completed(user_id: Int, db: sqlight.Connection) -> Nil {
  let sql =
    "
delete from
  items
where
  user_id = ?1
and
  completed = true
"
  let assert Ok(_) =
    sqlight.query(sql, on: db, with: [sqlight.int(user_id)], expecting: Ok)
  Nil
}

/// Toggle the completion state for specific item belonging to a user.
///
pub fn toggle_completion(
  item_id: Int,
  user_id: Int,
  db: sqlight.Connection,
) -> Result(Item, AppError) {
  let sql =
    "
update
  items
set
  completed = not completed
where
  id = ?1
and
  user_id = ?2
returning
  id,
  completed,
  content
"
  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(item_id), sqlight.int(user_id)],
      expecting: item_row_decoder(),
    )

  case rows {
    [completed] -> Ok(completed)
    _ -> Error(error.NotFound)
  }
}

pub fn any_completed(counts: Counts) -> Bool {
  counts.completed > 0
}

pub fn is_member(item: Item, category: Category) -> Bool {
  case category {
    All -> True
    Completed -> item.completed
    Active -> bool.negate(item.completed)
  }
}
