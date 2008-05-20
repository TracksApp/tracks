class ActiveRecord::Base
  module CommentingExtensions

    def comment_count
      commentable?
      self.comments.size
    end

    def comment_with(attributes)
      commentable?(true)
      begin
        comment = Comment.create(attributes)
        raise Comment::Error, "Comment could not be saved with" if comment.new_record?
        comment.commentables << self
      rescue
      end
    end

    private
    def commentable?(should_raise = false) #:nodoc:
      unless flag = respond_to?(:<%= parent_association_name -%>s)
        raise "#{self.class} is not a commentable model" if should_raise
      end
      flag
    end
  end

  include CommentingExtensions
end

