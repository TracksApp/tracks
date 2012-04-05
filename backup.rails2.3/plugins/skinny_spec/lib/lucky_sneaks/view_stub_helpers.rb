$:.unshift File.join(File.dirname(__FILE__), "..")
require "skinny_spec"

module LuckySneaks
  # These methods are designed to be used in your example <tt>before</tt> blocks to accomplish
  # a whole lot of functionality with just a tiny bit of effort.
  module ViewStubHelpers
    # Shorthand for the following stub:
    # 
    #   template.stub!(:render).with(hash_including(:partial => anything))
    def stub_partial_rendering!
      template.stub!(:render).with(hash_including(:partial => anything))
    end
  end
end