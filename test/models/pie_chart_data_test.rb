require 'minimal_test_helper'
require 'app/models/stats/pie_chart_data'
require 'active_support/core_ext/string'

class Stats::PieChartDataTest < Minitest::Test

  def test_with_0_items
    data = Stats::PieChartData.new([], 'a chart', 50)

    assert_equal [], data.values
    assert_equal [], data.labels
    assert_equal [], data.ids
  end

  def test_with_less_than_10_items
    items = [
      {'id' => 1, 'name' => 'one',   'total' => 11},
      {'id' => 2, 'name' => 'two',   'total' => 4},
      {'id' => 3, 'name' => 'three', 'total' => 8},
      {'id' => 4, 'name' => 'four',  'total' => 13},
      {'id' => 5, 'name' => 'five',  'total' => 20},
      {'id' => 6, 'name' => 'six',   'total' => 17},
      {'id' => 7, 'name' => 'seven', 'total' => 5},
      {'id' => 8, 'name' => 'eight', 'total' => 1},
      {'id' => 9, 'name' => 'nine',  'total' => 6}
    ]

    data = Stats::PieChartData.new(items, 'a chart', 50)

    assert_equal [12, 4, 9, 15, 23, 20, 5, 1, 7], data.values
    assert_equal ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"], data.labels
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9], data.ids
  end

  def test_with_exactly_10_items
    items = [
      {'id' => 1,  'name' => 'one',   'total' => 11},
      {'id' => 2,  'name' => 'two',   'total' => 4},
      {'id' => 3,  'name' => 'three', 'total' => 8},
      {'id' => 4,  'name' => 'four',  'total' => 13},
      {'id' => 5,  'name' => 'five',  'total' => 20},
      {'id' => 6,  'name' => 'six',   'total' => 17},
      {'id' => 7,  'name' => 'seven', 'total' => 5},
      {'id' => 8,  'name' => 'eight', 'total' => 1},
      {'id' => 9,  'name' => 'nine',  'total' => 6},
      {'id' => 10, 'name' => 'ten',   'total' => 19}
    ]

    data = Stats::PieChartData.new(items, 'a chart', 50)

    assert_equal [10, 3, 7, 12, 19, 16, 4, 0, 5, 18], data.values
    assert_equal ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"], data.labels
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], data.ids
  end

  def test_with_more_than_10_items
    items = [
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

    data = Stats::PieChartData.new(items, 'a chart', 50)

    assert_equal [9, 3, 6, 11, 16, 14, 4, 0, 5, 27], data.values
    assert_equal ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "(others)"], data.labels
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, -1], data.ids
  end

end
