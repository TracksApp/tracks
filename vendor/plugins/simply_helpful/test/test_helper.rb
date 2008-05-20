RAILS_ENV = 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'
require 'breakpoint'

class Post
  attr_reader :id
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def name
    @id.nil? ? 'new post' : "post ##{@id}"
  end
  class Nested < Post; end
end

class Test::Unit::TestCase
  protected
    def posts_url
      'http://www.example.com/posts'
    end
    
    def post_url(post)
      "http://www.example.com/posts/#{post.id}"
    end
end