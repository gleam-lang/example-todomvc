import gleam/pgo
import gleam/dynamic

pub fn create_user(db: pgo.Connection) -> Int {
  let sql = "
insert into users 
default values
returning
  id
"
  assert Ok(result) =
    pgo.execute(
      sql,
      on: db,
      with: [],
      expecting: dynamic.element(0, dynamic.int),
    )
  assert pgo.Returned(rows: [id], ..) = result
  id
}
