  def test_summary
    undone_todo_count = '5 actions'
    assert_equal "<p>#{undone_todo_count}. Context is Active.</p>", @agenda.summary(undone_todo_count)
    @agenda.hide = true
    @agenda.save!
    assert_equal "<p>#{undone_todo_count}. Context is Hidden.</p>", @agenda.summary(undone_todo_count)
  end
