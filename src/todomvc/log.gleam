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

external fn erlang_log(Level, String) -> Dynamic =
  "logger" "log"

type SetLogLevel {
  Level
}

external fn erlang_set_log_level(SetLogLevel, Level) -> Dynamic =
  "logger" "set_primary_config"

pub fn set_log_level(level: Level) -> Nil {
  erlang_set_log_level(Level, level)
  Nil
}

pub fn log(level: Level, message: String) -> Nil {
  erlang_log(level, message)
  Nil
}

// In future we could use the Erlang logger, but for now just print to standard
// output.
pub fn info(message: String) -> Nil {
  log(Info, message)
}
