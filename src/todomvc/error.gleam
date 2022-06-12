import gleam/pgo

pub type AppError {
  NotFound
  MethodNotAllowed
  UserNotFound
  BadRequest
  UnprocessableEntity
  ContentRequired
  PgoError(pgo.QueryError)
}
