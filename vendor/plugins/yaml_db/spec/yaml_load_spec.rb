require File.dirname(__FILE__) + '/base'

describe YamlDb::Load do
	before do
		ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true)
		ActiveRecord::Base.connection = mock('connection')
		ActiveRecord::Base.connection.stub!(:transaction).and_yield
	end

	before(:each) do
		@io = StringIO.new
	end

	it "should truncate the table" do
		ActiveRecord::Base.connection.stub!(:execute).with("TRUNCATE mytable").and_return(true)
		ActiveRecord::Base.connection.should_not_receive(:execute).with("DELETE FROM mytable")
		YamlDb::Load.truncate_table('mytable')
	end

	it "should delete the table if truncate throws an exception" do
		ActiveRecord::Base.connection.should_receive(:execute).with("TRUNCATE mytable").and_raise()
		ActiveRecord::Base.connection.should_receive(:execute).with("DELETE FROM mytable").and_return(true)
		YamlDb::Load.truncate_table('mytable')
	end

	it "should insert records into a table" do
		ActiveRecord::Base.connection.stub!(:quote_column_name).with('a').and_return('a')
		ActiveRecord::Base.connection.stub!(:quote_column_name).with('b').and_return('b')
		ActiveRecord::Base.connection.stub!(:quote).with(1).and_return("'1'")
		ActiveRecord::Base.connection.stub!(:quote).with(2).and_return("'2'")
		ActiveRecord::Base.connection.stub!(:quote).with(3).and_return("'3'")
		ActiveRecord::Base.connection.stub!(:quote).with(4).and_return("'4'")
		ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,b) VALUES ('1','2')")
		ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,b) VALUES ('3','4')")

		YamlDb::Load.load_records('mytable', ['a', 'b'], [[1, 2], [3, 4]])
	end

	it "should quote column names that correspond to sql keywords" do
		ActiveRecord::Base.connection.stub!(:quote_column_name).with('a').and_return('a')
		ActiveRecord::Base.connection.stub!(:quote_column_name).with('count').and_return('"count"')
		ActiveRecord::Base.connection.stub!(:quote).with(1).and_return("'1'")
		ActiveRecord::Base.connection.stub!(:quote).with(2).and_return("'2'")
		ActiveRecord::Base.connection.stub!(:quote).with(3).and_return("'3'")
		ActiveRecord::Base.connection.stub!(:quote).with(4).and_return("'4'")
		ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,\"count\") VALUES ('1','2')")
		ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,\"count\") VALUES ('3','4')")

		YamlDb::Load.load_records('mytable', ['a', 'count'], [[1, 2], [3, 4]])
	end

	it "should truncate the table and then load the records into the table" do
		YamlDb::Load.should_receive(:truncate_table).with('mytable')
		YamlDb::Load.should_receive(:load_records).with('mytable', ['a', 'b'], [[1, 2], [3, 4]])
		YamlDb::Load.should_receive(:reset_pk_sequence!).with('mytable')

		YamlDb::Load.load_table('mytable', { 'columns' => [ 'a', 'b' ], 'records' => [[1, 2], [3, 4]] })
	end

	it "should call load structure for each document in the file" do
		YAML.should_receive(:load_documents).with(@io).and_yield({ 'mytable' => { 
					'columns' => [ 'a', 'b' ], 
					'records' => [[1, 2], [3, 4]] 
				} })
		YamlDb::Load.should_receive(:load_table).with('mytable', { 'columns' => [ 'a', 'b' ], 'records' => [[1, 2], [3, 4]] })
		YamlDb::Load.load(@io)
	end

	it "should not call load structure when the document in the file contains no records" do
		YAML.should_receive(:load_documents).with(@io).and_yield({ 'mytable' => nil })
		YamlDb::Load.should_not_receive(:load_table)
		YamlDb::Load.load(@io)
	end

	it "should call reset pk sequence if the connection adapter is postgres" do
		module ActiveRecord; module ConnectionAdapters; class PostgreSQLAdapter; end; end; end;
		ActiveRecord::Base.connection.stub!(:kind_of?).with(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).and_return(true)
		ActiveRecord::Base.connection.should_receive(:reset_pk_sequence!).with('mytable')
		YamlDb::Load.reset_pk_sequence!('mytable')
	end

	it "should not call reset_pk_sequence if the connection adapter is not postgres" do
		module ActiveRecord; module ConnectionAdapters; class PostgreSQLAdapter; end; end; end;
		ActiveRecord::Base.connection.stub!(:kind_of?).with(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).and_return(false)
		ActiveRecord::Base.connection.should_not_receive(:reset_pk_sequence!)
		YamlDb::Load.reset_pk_sequence!('mytable')
	end
end
