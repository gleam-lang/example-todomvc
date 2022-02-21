import gleam/pgo
import gleam/int
import gleam/result
import gleam/crypto
import gleam/dynamic
import gleam/bit_string
import todomvc/error.{AppError}
import todomvc/log

/// Insert a new user, returning their id.
///
pub fn insert_user(db: pgo.Connection) -> Int {
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

pub fn verify_cookie_id(id: String, secret: String) -> Result(Int, AppError) {
  crypto.verify_signed_message(id, <<secret:utf8>>)
  |> result.then(bit_string.to_string)
  |> result.then(int.parse)
  |> result.map_error(fn(_) {
    log.info("Ignoring bad uid cookie")
    error.BadRequest
  })
}
