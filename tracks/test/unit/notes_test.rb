require File.dirname(__FILE__) + '/../test_helper'

class NotesTest < Test::Rails::TestCase
  fixtures :notes

  def setup
    @notes = Note.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Note,  @notes
  end
end
