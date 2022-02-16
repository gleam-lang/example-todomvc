import gleeunit/should
import todomvc/web

pub fn escape_test() {
  "&& <script>alert(1)</script> &&"
  |> web.escape
  |> should.equal("&amp;&amp; &lt;script&gt;alert(1)&lt;/script&gt; &amp;&amp;")
}
