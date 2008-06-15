require File.dirname(__FILE__) + '/base'

describe YamlDb::Utils, " convert records utility method" do
	it "turns an array with one record into a yaml chunk" do
		YamlDb::Utils.chunk_records([ %w(a b) ]).should == <<EOYAML
  - - a
    - b
EOYAML
	end

	it "turns an array with two records into a yaml chunk" do
		YamlDb::Utils.chunk_records([ %w(a b), %w(x y) ]).should == <<EOYAML
  - - a
    - b
  - - x
    - y
EOYAML
	end

	it "returns an array of hash values using an array of ordered keys" do
		YamlDb::Utils.unhash({ 'a' => 1, 'b' => 2 }, [ 'b', 'a' ]).should == [ 2, 1 ]
	end

	it "should unhash each hash an array using an array of ordered keys" do
		YamlDb::Utils.unhash_records([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ], [ 'b', 'a' ]).should == [ [ 2, 1 ], [ 4, 3 ] ]
	end

	it "should return true if it is a boolean type" do
		YamlDb::Utils.is_boolean(true).should == true
		YamlDb::Utils.is_boolean('true').should_not == true
	end

	it "should return an array of boolean columns" do
		ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true)
		ActiveRecord::Base.connection = mock('connection')
		ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([ mock('a',:name => 'a',:type => :string), mock('b', :name => 'b',:type => :boolean) ])
		YamlDb::Utils.boolean_columns('mytable').should == ['b']
	end
end
