import gleam/io
import gleam/string

pub fn info(message: String) -> Nil {
  io.println(string.append("INFO ", message))
}
