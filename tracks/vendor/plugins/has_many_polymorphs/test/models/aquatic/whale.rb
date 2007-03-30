# see http://dev.rubyonrails.org/ticket/5935
module Aquatic; end
require 'aquatic/fish'
require 'aquatic/pupils_whale'

class Aquatic::Whale < ActiveRecord::Base
  has_many_polymorphs(:aquatic_pupils, :from => [:dogs, :"aquatic/fish"],
                      :through => "aquatic/pupils_whales") do 
                        def blow; "result"; end
                      end
end
