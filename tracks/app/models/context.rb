class Context < ActiveRecord::Base
    has_many :todo, :dependent => true
end
