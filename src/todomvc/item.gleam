import gleam/pgo
import gleam/list
import gleam/bool
import gleam/result
import gleam/dynamic
import todomvc/error.{AppError}

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
    dynamic.element(1, dynamic.bool),
    dynamic.element(2, dynamic.string),
  )
}

/// Count the number of completed and active items in the database for a user.
///
pub fn get_counts(user_id: Int, db: pgo.Connection) -> Counts {
  let sql =
    "
select 
  completed,
  count(*)
from
  items
where
  items.user_id = $1
group by
  completed
order by
  completed asc
"
  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(user_id)],
      expecting: dynamic.tuple2(dynamic.bool, dynamic.int),
    )
  let completed =
    result.rows
    |> list.key_find(True)
    |> result.unwrap(0)
  let active =
    result.rows
    |> list.key_find(False)
    |> result.unwrap(0)
  Counts(active: active, completed: completed)
}

/// Insert a new item for a given user.
///
pub fn insert_item(
  content: String,
  user_id: Int,
  db: pgo.Connection,
) -> Result(Int, AppError) {
  let sql =
    "
insert into items
  (content, user_id) 
values 
  ($1, $2)
returning
  id
"
  try result =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.text(content), pgo.int(user_id)],
      expecting: dynamic.element(0, dynamic.int),
    )
    |> result.replace_error(error.UserNotFound)

  assert [id] = result.rows
  Ok(id)
}

/// Get a specific item for a user.
///
pub fn get_item(
  item_id: Int,
  user_id: Int,
  db: pgo.Connection,
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
  id = $1
and
  user_id = $2
"

  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(item_id), pgo.int(user_id)],
      expecting: item_row_decoder(),
    )

  case result.rows {
    [item] -> Ok(item)
    _ -> Error(error.NotFound)
  }
}

/// List all the items for a user that have a particular completion state.
///
pub fn filtered_items(
  user_id: Int,
  completed: Bool,
  db: pgo.Connection,
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
  user_id = $1
and
  completed = $2
order by
  inserted_at desc
"

  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(user_id), pgo.bool(completed)],
      expecting: item_row_decoder(),
    )

  result.rows
}

/// List all the items for a user.
///
pub fn list_items(user_id: Int, db: pgo.Connection) -> List(Item) {
  let sql =
    "
select
  id,
  completed,
  content
from
  items
where
  user_id = $1
order by
  inserted_at desc
"

  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(user_id)],
      expecting: item_row_decoder(),
    )

  result.rows
}

/// Delete a specific item belonging to a user.
///
pub fn delete_item(item_id: Int, user_id: Int, db: pgo.Connection) -> Bool {
  let sql = "
delete from
  items
where
  id = $1
and
  user_id = $2
"
  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(item_id), pgo.int(user_id)],
      expecting: Ok,
    )
  result.count > 0
}

/// Update the content of a specific item belonging to a user.
///
pub fn update_item(
  item_id: Int,
  user_id: Int,
  content: String,
  db: pgo.Connection,
) -> Result(Item, AppError) {
  let sql =
    "
update
  items
set
  content = $3
where
  id = $1
and
  user_id = $2
returning
  id,
  completed,
  content
"
  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(item_id), pgo.int(user_id), pgo.text(content)],
      expecting: item_row_decoder(),
    )
  case result.rows {
    [item] -> Ok(item)
    _ -> Error(error.NotFound)
  }
}

/// Delete a specific item belonging to a user.
///
pub fn delete_completed(user_id: Int, db: pgo.Connection) -> Int {
  let sql = "
delete from
  items
where
  user_id = $1
and
  completed = true
"
  assert Ok(result) =
    pgo.execute(sql, on: db, with: [pgo.int(user_id)], expecting: Ok)
  result.count
}

/// Toggle the completion state for specific item belonging to a user.
///
pub fn toggle_completion(
  item_id: Int,
  user_id: Int,
  db: pgo.Connection,
) -> Result(Item, AppError) {
  let sql =
    "
update
  items
set
  completed = not completed
where
  id = $1
and
  user_id = $2
returning
  id,
  completed,
  content
"
  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(item_id), pgo.int(user_id)],
      expecting: item_row_decoder(),
    )

  case result.rows {
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
