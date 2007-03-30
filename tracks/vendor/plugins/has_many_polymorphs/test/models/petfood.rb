# see http://dev.rubyonrails.org/ticket/5935
require 'eaters_foodstuff'
require 'petfood'
require 'cat'
module Aquatic; end
require 'aquatic/fish'
require 'dog'
require 'wild_boar'
require 'kitten'
require 'tabby'

class Petfood < ActiveRecord::Base
  set_primary_key 'the_petfood_primary_key'
  has_many_polymorphs :eaters, 
                                    :from => [:dogs, :petfoods, :wild_boars, :kittens, 
                                                    :tabbies, :"aquatic/fish"], 
                                    :dependent => :destroy, 
                                    :rename_individual_collections => true,
                                    :acts_as => :foodstuff,
                                    :foreign_key => "foodstuff_id"
end
