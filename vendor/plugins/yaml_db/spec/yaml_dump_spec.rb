require File.dirname(__FILE__) + '/base'

describe YamlDb::Dump do
	before do
		File.stub!(:new).with('dump.yml', 'w').and_return(StringIO.new)

		ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true)
		ActiveRecord::Base.connection = mock('connection')
		ActiveRecord::Base.connection.stub!(:tables).and_return([ 'mytable' ])
		ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([ mock('a',:name => 'a'), mock('b', :name => 'b') ])
		ActiveRecord::Base.connection.stub!(:select_one).and_return({"count"=>"2"})
		ActiveRecord::Base.connection.stub!(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
	end

	before(:each) do
		@io = StringIO.new
	end

	it "should return a formatted string" do
		YamlDb::Dump.table_record_header(@io)
		@io.rewind
		@io.read.should == "  records: \n"
	end

	it "should return a list of column names" do
		YamlDb::Dump.table_column_names('mytable').should == [ 'a', 'b' ]
	end

	it "should return the total number of records in a table" do
		YamlDb::Dump.table_record_count('mytable').should == 2
	end

	it "should return a yaml string that contains a table header and column names" do
		YamlDb::Dump.stub!(:table_column_names).with('mytable').and_return([ 'a', 'b' ])
		YamlDb::Dump.dump_table_columns(@io, 'mytable')
		@io.rewind
		@io.read.should == <<EOYAML

--- 
mytable: 
  columns: 
  - a
  - b
EOYAML
	end

	it "should return all records from the database and return them when there is only 1 page" do
		YamlDb::Dump.each_table_page('mytable') do |records|
			records.should == [ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ]
		end
	end

	it "should paginate records from the database and return them" do
		ActiveRecord::Base.connection.stub!(:select_all).and_return([ { 'a' => 1, 'b' => 2 } ], [ { 'a' => 3, 'b' => 4 } ])

		records = [ ]
		YamlDb::Dump.each_table_page('mytable', 1) do |page|
			page.size.should == 1
			records.concat(page)
		end

		records.should == [ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ]
	end

	it "should return dump the records for a table in yaml to a given io stream" do
		YamlDb::Dump.dump_table_records(@io, 'mytable')
		@io.rewind
		@io.read.should == <<EOYAML
  records: 
  - - 1
    - 2
  - - 3
    - 4
EOYAML
	end

	it "should dump a table's contents to yaml" do
		YamlDb::Dump.should_receive(:dump_table_columns)
		YamlDb::Dump.should_receive(:dump_table_records)
		YamlDb::Dump.dump_table(@io, 'mytable')
	end

	it "should not dump a table's contents when the record count is zero" do
		YamlDb::Dump.stub!(:table_record_count).with('mytable').and_return(0)
		YamlDb::Dump.should_not_receive(:dump_table_columns)
		YamlDb::Dump.should_not_receive(:dump_table_records)
		YamlDb::Dump.dump_table(@io, 'mytable')
	end
end
