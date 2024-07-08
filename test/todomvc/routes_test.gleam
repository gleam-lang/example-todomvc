import gleam/int
import gleam/string
import gleeunit/should
import todomvc/item
import todomvc/router
import todomvc/tests
import todomvc/user
import wisp
import wisp/testing

pub fn home_test() {
  use ctx <- tests.with_context

  let uid1 = user.insert_user(ctx.db)
  let assert Ok(_) = item.insert_item("Wibble", uid1, ctx.db)
  let assert Ok(_) = item.insert_item("Wobble", uid1, ctx.db)
  let uid2 = user.insert_user(ctx.db)
  let assert Ok(_) = item.insert_item("Wabble", uid2, ctx.db)

  let request =
    testing.get("/", [])
    |> testing.set_cookie("uid", int.to_string(uid1), wisp.Signed)
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(200)

  let body = testing.string_body(response)

  body
  |> string.contains("Wibble")
  |> should.equal(True)

  body
  |> string.contains("Wobble")
  |> should.equal(True)

  // An item belonging to another user is not included
  body
  |> string.contains("Wabble")
  |> should.equal(False)
}
