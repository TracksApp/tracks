  require File.dirname(__FILE__) + '/test_helper'

class SeleneseTest < Test::Unit::TestCase
  
  def setup
    @view = TestView.new
    @view.extend(SeleniumOnRails::PathsTestHelper)
    @sel = SeleniumOnRails::Selenese.new(@view) 
  end
  
  def render_selenese(page_title, input)
    create_sel_file_from(input, "html.sel")
    
    @sel.render ActionView::Template.new(test_path_for("html.sel")), {'page_title' => page_title}
  end
  
  def create_sel_file_from(input, name)
    File.open(test_path_for(name), 'w+') { |index_file| index_file << input }
  end
  
  def test_path_for(name)
    "#{File.expand_path(File.dirname(__FILE__) + "/../test_data")}/#{name}"
  end
   
  def assert_selenese expected, name, input
    assert_text_equal expected, render_selenese(name, input)
  end
   
  def test_empty
    expected = <<END
<table>
<tr><th colspan="3">Empty</th></tr>
</table>
END
    input = ''
    assert_selenese expected, 'Empty', ''
  end
   
  def test_one_line
    expected = <<END
<table>
<tr><th colspan="3">One line</th></tr>
<tr><td>open</td><td>/</td><td>&nbsp;</td></tr>
</table>
END
    input = '|open|/|'
    assert_selenese expected, 'One line', input
  end
   
  def test_comments_only
    expected = <<END
<p>Comment <strong>1</strong></p>


<p>Comment 2</p>
<table>
<tr><th colspan="3">Only comments</th></tr>
</table>
END
    input = <<END
Comment *1*
 
Comment 2
 
END
    assert_selenese expected, 'Only comments', input
  end
   
  def test_commands_only
    expected = <<END
<table>
<tr><th colspan="3">Only commands</th></tr>
<tr><td>goBack</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>open</td><td>/foo</td><td>&nbsp;</td></tr>
<tr><td>fireEvent</td><td>textField</td><td>focus</td></tr>
</table>
END
    input = <<END

|goBack   |

|open|   /foo  |  
| fireEvent | textField | focus |


END
    assert_selenese expected, 'Only commands', input
  end
   
  def test_commands_and_comments
    expected = <<END
<table>
<tr><th colspan="3">Commands and comments</th></tr>
<tr><td>goBack</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>fireEvent</td><td>textField</td><td>focus</td></tr>
</table>
<p>Comment 1</p>


 <p>Comment <strong>2</strong></p>
END
    input = <<END

|goBack   |

|  fireEvent | textField| focus|
Comment 1

Comment *2*

END
    assert_selenese expected, 'Commands and comments', input
  end
   
  def test_comments_and_commands
    expected = <<END
<p>Comment 1</p>
 
<p>Comment <strong>2</strong></p>
<table>
<tr><th colspan="3">Comments and commands</th></tr>
<tr><td>goBack</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>fireEvent</td><td>textField</td><td>focus</td></tr>
</table>
END
    input = <<END
Comment 1

Comment *2*
|goBack   |

|  fireEvent | textField|focus|

END
    assert_selenese expected, 'Comments and commands', input
  end
   
  def test_comments_commands_comments
    expected = <<END
<p>Comment 1</p>
<p>Comment <strong>2</strong></p>
<table>
<tr><th colspan="3">Comments, commands and comments</th></tr>
<tr><td>goBack</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><td>fireEvent</td><td>textField</td><td>focus</td></tr>
</table>
<p>Comment 3</p>
END
    
    input = <<END
Comment 1

Comment *2*
|goBack   |
|  fireEvent | textField| focus|
Comment 3
END
    assert_selenese expected, 'Comments, commands and comments', input
  end
   
  def test_command_html_entity_escaping
    expected = <<END
<table>
<tr><th colspan="3">HTML escaping</th></tr>
<tr><td>type</td><td>nameField</td><td>&lt;&gt;&amp;</td></tr>
</table>
END
    input = '|type|nameField|<>&|'
    assert_selenese expected, 'HTML escaping', input
  end
   
  def test_partial_support
    expected = <<END
<table>
<tr><th colspan="3">Partial support</th></tr>
<tr><td>type</td><td>partial</td><td>Selenese partial</td></tr>
</table>
END
    input = '|includePartial|override|'
    partial = '|type|partial|Selenese partial|'
    create_sel_file_from(partial, "_override.sel")
    
    assert_selenese(expected, 'Partial support', input)
    
    File.delete(test_path_for("_override.sel"))
  end
   
  def test_partial_support_with_local_assigns
    expected = <<END_EXPECTED
<table>
<tr><th colspan="3">Partial support with local assigns</th></tr>
<tr><td>type</td><td>assigns</td><td>a=hello,b=world!,c_123ABC=</td></tr>
<tr><td>type</td><td>assigns</td><td>a=a b c d,b=,c_123ABC=hello</td></tr>
</table>
END_EXPECTED
     
    input = <<END_INPUT
|includePartial|override|a=hello|b=world!|
|includePartial|override|a = a b c d|b=|c_123ABC= hello  |
END_INPUT

    partial = <<END_PARTIAL
<table><tr><th>whatever</th></tr>
<tr><td>type</td><td>assigns</td><td>
a=<%= a if defined? a%>,
b=<%= b if defined? b%>,
c_123ABC=<%= c_123ABC if defined? c_123ABC%>
</td></tr>
</table>
END_PARTIAL

    create_sel_file_from(partial, "_override.html")
    
    assert_selenese(expected, 'Partial support with local assigns', input)
    
    File.delete(test_path_for("_override.html"))
  end
     
  def test_raised_when_more_than_three_columns
    assert_raise RuntimeError, 'There might only be a maximum of three cells!' do
      render_selenese 'name', '|col1|col2|col3|col4|'
    end
  end
 
  def test_raised_when_more_than_one_set_of_commands
    assert_raise RuntimeError, 'You cannot have comments in the middle of commands!' do
      input = <<END
comment
|command|
comment
|command|
END
      render_selenese 'name', input
    end
  end
   
  def test_raised_when_incorrect_partial_format
    assert_raise RuntimeError, "Invalid format 'invalid'. Should be '|includePartial|partial|var1=value|var2=value|." do
      render_selenese 'name', '|includePartial|partial|a=valid|invalid|'
    end
  end
end
