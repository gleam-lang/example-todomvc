import sqlight
import gleam/dynamic

/// Insert a new user, returning their id.
///
pub fn insert_user(db: sqlight.Connection) -> Int {
  let sql =
    "
insert into users
default values 
returning id;
"
  let assert Ok([id]) =
    sqlight.query(
      sql,
      on: db,
      with: [],
      expecting: dynamic.element(0, dynamic.int),
    )

  id
}
