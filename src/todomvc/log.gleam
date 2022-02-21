import gleam/io
import gleam/string

// In future we could use the Erlang logger, but for now just print to standard
// output.
pub fn info(message: String) -> Nil {
  io.println(string.append("INFO ", message))
}
