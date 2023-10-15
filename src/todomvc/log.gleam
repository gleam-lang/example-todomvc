import gleam/dynamic.{Dynamic}

pub type Level {
  Emergency
  Alert
  Critical
  Error
  Warning
  Notice
  Info
  Debug
}

/// Configure the Erlang logger to use the log level and output format that we
/// want, rather than the more verbose Erlang default format.
///
@external(erlang, "todomvc_ffi", "configure_logger_backend")
pub fn configure_backend() -> Nil

@external(erlang, "logger", "log")
fn erlang_log(level: Level, message: String) -> Dynamic

pub fn log(level: Level, message: String) -> Nil {
  erlang_log(level, message)
  Nil
}

pub fn info(message: String) -> Nil {
  log(Info, message)
}
