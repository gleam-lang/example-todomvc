import gleam/pgo
import gleam/dynamic

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

pub fn insert_item() -> Nil {
  "
insert into items
  (content, user_id) 
values 
  ($1, $2)
"
  todo
}

pub fn list_items() -> Nil {
  "
select
  id,
  user_id,
  content
from
  items
where
  user_id = $1
"
  todo
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
