class Test::Unit::TestCase
  
  # http://project.ioni.st/post/217#post-217
  #
  #  def test_new_publication
  #    assert_difference(Publication, :count) do
  #      post :create, :publication => {...}
  #      # ...
  #    end
  #  end
  #
  # modified by mabs29 to include arguments
  def assert_difference(object, method = nil, difference = 1, *args)
    initial_value = object.send(method, *args)
    yield
    assert_equal initial_value + difference, object.send(method, *args), "#{object}##{method}"
  end

  def assert_no_difference(object, method, *args, &block)
    assert_difference object, method, 0, *args, &block
  end

end
