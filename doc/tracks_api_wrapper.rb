require 'activeresource'

# WARNING: this is not really maintained or tested...

# Install the ActiveResource gem if you don't already have it:
#
# sudo gem install activeresource --source http://gems.rubyonrails.org --include-dependencies

# $ SITE="http://myusername:p4ssw0rd@mytracksinstallation.com" irb -r tracks_api_wrapper.rb
# 
# >> my_pc = Tracks::Context.find(:first)
# => #<Tracks::Context:0x139c3c0 @prefix_options={}, @attributes={"name"=>"my pc", "updated_at"=>Mon Aug 13 02:56:18 UTC 2007, "hide"=>0, "id"=>8, "position"=>1, "created_at"=>Wed Feb 28 07:07:28 UTC 2007}
# >> my_pc.name
# => "my pc"
# >> my_pc.todos
# => [#<Tracks::Todo:0x1e16b84 @prefix_options={}, @attributes={"context_id"=>8, "completed_at"=>Tue Apr 10 12:57:24 UTC 2007, "project_id"=>nil, "show_from"=>nil, "id"=>1432, "notes"=>nil, "description"=>"check rhino mocks bug", "due"=>Mon, 09 Apr 2007, "created_at"=>Sun Apr 08 04:56:35 UTC 2007, "state"=>"completed"}, #<Tracks::Todo:0x1e16b70 @prefix_options={}, @attributes={"context_id"=>8, "completed_at"=>Mon Oct 10 13:10:21 UTC 2005, "project_id"=>10, "show_from"=>nil, "id"=>17, "notes"=>"fusion problem", "description"=>"Fix Client Installer", "due"=>nil, "created_at"=>Sat Oct 08 00:19:33 UTC 2005, "state"=>"completed"}]
#
# >> t = Tracks::Todo.new
# => #<Tracks::Todo:0x1ee9fc0 @prefix_options={}, @attributes={}>
# >> t.description = "do it now"
# => "do it now"
# >> t.context_id = 8
# => 8
# >> t.save
# => true
# >> t.reload
# => #<Tracks::Todo:0x1ee9fc0 @prefix_options={}, @attributes={"completed_at"=>nil, "context_id"=>8, "project_id"=>nil, "show_from"=>nil, "notes"=>nil, "id"=>1791, "description"=>"do it now", "due"=>nil, "created_at"=>Mon Dec 03 19:15:46 UTC 2007, "state"=>"active"}
# >> t.put(:toggle_check)
# => #<Net::HTTPOK 200 OK readbody=true>
# >> t.reload
# => #<Tracks::Todo:0x1ee9fc0 @prefix_options={}, @attributes={"completed_at"=>Mon Dec 03 19:17:46 UTC 2007, "context_id"=>8, "project_id"=>nil, "show_from"=>nil, "notes"=>nil, "id"=>1791, "description"=>"do it now", "due"=>nil, "created_at"=>Mon Dec 03 19:15:46 UTC 2007, "state"=>"completed"}

# If you want to see the HTTP requests and responses that are being passed back and
# forth, you can tweak your active_resource like as described in:
#   http://blog.pepperdust.org/2007/2/13/enabling-wire-level-debug-output-for-activeresource

module Tracks
  
  class Base < ActiveResource::Base
    self.site = ENV["SITE"] || "http://username:password@0.0.0.0:3000/"
  end
  
  class Todo < Base
  end  
  
  class Context < Base
    def todos
      return attributes["todos"] if attributes.keys.include?("todos")
      return Todo.find(:all, :params => {:context_id => id})
    end    
  end

  class Project < Base
    def todos
      return attributes["todos"] if attributes.keys.include?("todos")
      return Todo.find(:all, :params => {:project_id => id})
    end    
  end
  
end