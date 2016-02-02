require "test_helper"

class RenderingHelperTest < ActionView::TestCase
  include RenderingHelper

  test "auto_link_message" do
    html = "This is a sample with a message - message://<123456789>. There we go."
    rendered_html = auto_link_message(html)
    assert(
      rendered_html.include?(%|<a href="message://&lt;123456789&gt;">message://&lt;123456789&gt;</a>|),
      "Message was not correctly rendered. Rendered message:\n#{rendered_html}"
    )

    html = %|This message is already tagged: <a href="message://<12345>">Call bob</a>."|
    rendered_html = auto_link_message(html)
    assert_equal(html, rendered_html)
  end

  test "textile" do
    raw_textile = "This should end up *strong*."
    rendered_textile = textile(raw_textile)
    assert_equal("<p>This should end up <strong>strong</strong>.</p>", rendered_textile)
  end

  test "render_text" do
    simple_textile = render_text("This is *strong*.")
    assert_equal("<p>This is <strong>strong</strong>.</p>", simple_textile)

    autolink_message = render_text("Call message://<123>.")
    assert_equal(%|<p>Call <a href="message://&lt;123&gt;">message://&lt;123&gt;</a>.</p>|, autolink_message)

    onenote_links = render_text(%|Link to onenote <a href="onenote://foobar">here</a>.|)
    assert_equal(%|<p>Link to onenote <a href="onenote://foobar">here</a>.</p>|, onenote_links)
  end
end
