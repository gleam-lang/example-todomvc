import gleam/io
import gleam/dynamic.{Dynamic}
import gleam/string

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
pub external fn configure_backend() -> Nil =
  "todomvc_ffi" "configure_logger_backend"

external fn erlang_log(Level, String) -> Dynamic =
  "logger" "log"

pub fn log(level: Level, message: String) -> Nil {
  erlang_log(level, message)
  Nil
}

pub fn info(message: String) -> Nil {
  log(Info, message)
}
