require "test_helper"

class RenderingHelperTest < ActionView::TestCase
  include RenderingHelper

  test "textile markup" do
    actual = render_text("This is *strong*.")
    assert_equal("<p>This is <strong>strong</strong>.</p>", actual)
  end

  test "onenote link" do
    url = 'onenote:///E:\OneNote\dir\notes.one#PAGE&section-id={FD597D3A-3793-495F-8345-23D34A00DD3B}&page-id={1C95A1C7-6408-4804-B3B5-96C28426022B}&end'
    actual = render_text(url)
    expected = '<p>onenote:///E:\OneNote\dir\notes.one#<span class="caps">PAGE</span>&amp;section-id={FD597D3A-3793-495F-8345-23D34A00DD3B}&amp;page-id={1C95A1C7-6408-4804-B3B5-96C28426022B}&amp;end</p>'
    assert_equal(expected, actual)
  end

  test "textile onenote link" do
    url = '"link me to onenote":onenote://foo/bar'
    actual = render_text(url)
    expected = '<p><a href="onenote://foo/bar">link me to onenote</a></p>'
    assert_equal(expected, actual)
  end

  test "tagged onenote link" do
    actual = render_text('Link to onenote <a href="onenote://foobar">here</a>.')
    assert_equal('<p>Link to onenote <a href="onenote://foobar">here</a>.</p>', actual)
  end

  test "message link" do
    actual = render_text("Call message://<123>.")
    assert_equal('<p>Call <a href="message://&lt;123&gt;">message://&lt;123&gt;</a>.</p>', actual)
  end

  test "tagged message link" do
    expected = '<p>This message is already tagged: <a href="message://&lt;12345&gt;">Call bob</a>.</p>'
    actual = render_text(expected)
    assert_equal(expected, actual)
  end

  test "http link (in new window)" do
    actual = render_text("A link to http://github.com/.")
    expected = '<p>A link to <a target="_blank" href="http://github.com/">http://github.com/</a>.</p>'
    assert_equal(expected, actual)
  end

  test "http link (with double hyphens)" do
    skip("see issue #2056")

    actual = render_text("http://foo.bar/foo--bar")
    expected = '<p><a target="_blank" href="http://foo.bar/foo--bar">http://foo.bar/foo--bar</a></p>'
    assert_equal(expected, actual)
  end

  test "textile http link" do
    actual = render_text('A link to "GitHub":http://github.com/.')
    expected = '<p>A link to <a href="http://github.com/">GitHub</a>.</p>'
    assert_equal(expected, actual)
  end

  test "textile http link (in new window)" do
    skip("see issue #2066")

    actual = render_text('A link to "GitHub":http://github.com/.')
    expected = '<p>A link to <a target="_blank" href="http://github.com/">GitHub</a>.</p>'
    assert_equal(expected, actual)
  end

  test "url with slash in query string" do
    # See http://blog.swivel.com/code/2009/06/rails-auto_link-and-certain-query-strings.html
    actual = render_text("foo http://example.com/foo?bar=/baz bar")
    expected = '<p>foo <a target="_blank" href="http://example.com/foo?bar=/baz">http://example.com/foo?bar=/baz</a> bar</p>'
    assert_equal(expected, actual)
  end
end
