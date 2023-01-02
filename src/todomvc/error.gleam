import sqlight

pub type AppError {
  NotFound
  MethodNotAllowed
  UserNotFound
  BadRequest
  UnprocessableEntity
  ContentRequired
  SqlightError(sqlight.Error)
}
