import gleam/pgo
import gleam/dynamic
import gleam/result
import todomvc/error.{AppError}

pub type Item {
  Item(id: Int, completed: Bool, content: String)
}

pub fn get_counts() -> Nil {
  "
select 
  completed,
  count(*)
from
  items
where
  item.user_id = $1
group by
  completed
"
  todo
}

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
"

  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(user_id)],
      expecting: dynamic.decode3(
        Item,
        dynamic.element(0, dynamic.int),
        dynamic.element(1, dynamic.bool),
        dynamic.element(2, dynamic.string),
      ),
    )

  result.rows
}

pub fn delete_item() -> Nil {
  "
delete from
  items
where
  id = $1
and
  user_id = $2
"
  todo
}

pub fn toggle_completion(
  item_id: Int,
  user_id: Int,
  db: pgo.Connection,
) -> Result(Bool, Nil) {
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
  completed
"
  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [pgo.int(item_id), pgo.int(user_id)],
      expecting: dynamic.element(0, dynamic.bool),
    )

  case result.rows {
    [completed] -> Ok(completed)
    _ -> Error(Nil)
  }
}
