class Seller < ActiveRecord::Base
  belongs_to :user  
  delegate :address, :to => :user
end
