require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContextActionsDataTest < ActionController::TestCase
  tests StatsController

  def test_total_with_0_items
    login_as(:admin_user)
    Stats::TopContextsQuery.any_instance.stubs(:result).returns []

    get :context_total_actions_data

    expected = "&title=Spread of actions for all contexts,{font-size:16}&\n&pie=70,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=&\n&pie_labels=&\n&links=&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"
    assert_equal expected, @response.body.chomp
  end

  def test_total_with_less_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    expected = "&title=Spread of actions for all contexts,{font-size:16}&\n&pie=70,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=12,4,9,15,23,20,5,1,7&\n&pie_labels=one,two,three,four,five,six,seven,eight,nine&\n&links=/contexts/1,/contexts/2,/contexts/3,/contexts/4,/contexts/5,/contexts/6,/contexts/7,/contexts/8,/contexts/9&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"

    assert_equal expected, @response.body.chomp
  end

  def test_total_with_exactly_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    expected = "&title=Spread of actions for all contexts,{font-size:16}&\n&pie=70,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=10,3,7,12,19,16,4,0,5,18&\n&pie_labels=one,two,three,four,five,six,seven,eight,nine,ten&\n&links=/contexts/1,/contexts/2,/contexts/3,/contexts/4,/contexts/5,/contexts/6,/contexts/7,/contexts/8,/contexts/9,/contexts/10&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"

    assert_equal expected, @response.body.chomp
  end

  def test_total_with_more_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19},
      {'id' => 11, 'name' => 'eleven', 'total' => 14}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_total_actions_data

    expected = "&title=Spread of actions for all contexts,{font-size:16}&\n&pie=70,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=9,3,6,11,16,14,4,0,5,27&\n&pie_labels=one,two,three,four,five,six,seven,eight,nine,(others)&\n&links=/contexts/1,/contexts/2,/contexts/3,/contexts/4,/contexts/5,/contexts/6,/contexts/7,/contexts/8,/contexts/9,/contexts/-1&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"

    assert_equal expected, @response.body.chomp
  end

  def test_running_with_0_items
    login_as(:admin_user)
    Stats::TopContextsQuery.any_instance.stubs(:result).returns []

    get :context_running_actions_data

    expected = "&title=Spread of running actions for visible contexts,{font-size:16}&\n&pie=60,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=&\n&pie_labels=&\n&links=&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"
    assert_equal expected, @response.body.chomp
  end

  def test_running_with_less_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    expected = "&title=Spread of running actions for visible contexts,{font-size:16}&\n&pie=60,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=12,4,9,15,23,20,5,1,7&\n&pie_labels=one,two,three,four,five,six,seven,eight,nine&\n&links=/contexts/1,/contexts/2,/contexts/3,/contexts/4,/contexts/5,/contexts/6,/contexts/7,/contexts/8,/contexts/9&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"

    assert_equal expected, @response.body.chomp
  end

  def test_running_with_exactly_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    expected = "&title=Spread of running actions for visible contexts,{font-size:16}&\n&pie=60,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=10,3,7,12,19,16,4,0,5,18&\n&pie_labels=one,two,three,four,five,six,seven,eight,nine,ten&\n&links=/contexts/1,/contexts/2,/contexts/3,/contexts/4,/contexts/5,/contexts/6,/contexts/7,/contexts/8,/contexts/9,/contexts/10&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"

    assert_equal expected, @response.body.chomp
  end

  def test_running_with_more_than_10_items
    login_as(:admin_user)
    contexts = [
      {'id' => 1, 'name' => 'one', 'total' => 11},
      {'id' => 2, 'name' => 'two', 'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four', 'total' => 13},
      {'id' => 5, 'name' => 'five', 'total' => 20},
      {'id' => 6, 'name' => 'six', 'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine', 'total' => 6},
      {'id' => 10, 'name' => 'ten', 'total' => 19},
      {'id' => 11, 'name' => 'eleven', 'total' => 14}
    ]
    Stats::TopContextsQuery.any_instance.stubs(:result).returns contexts

    get :context_running_actions_data

    expected = "&title=Spread of running actions for visible contexts,{font-size:16}&\n&pie=60,#505050,{font-size: 12px; color: #404040;}&\n&x_axis_steps=1& &y_ticks=5,10,5& &line=3,#87421F& &y_min=0& &y_max=20&\n&values=9,3,6,11,16,14,4,0,5,27&\n&pie_labels=one,two,three,four,five,six,seven,eight,nine,(others)&\n&links=/contexts/1,/contexts/2,/contexts/3,/contexts/4,/contexts/5,/contexts/6,/contexts/7,/contexts/8,/contexts/9,/contexts/-1&\n&colours=#d01f3c,#356aa0,#C79810,#c61fd0,#1fc6d0,#1fd076,#72d01f,#c6d01f,#d0941f,#40941f&\n&tool_tip=#x_label#: #val#%25&\n&x_label_style=9,,2,1&"

    assert_equal expected, @response.body.chomp
  end

end
