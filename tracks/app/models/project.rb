class Project < ActiveRecord::Base
    has_many :todo, :dependent => true
end
