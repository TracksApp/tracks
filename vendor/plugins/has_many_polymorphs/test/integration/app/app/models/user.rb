class User < ActiveRecord::Base
  has_one   :seller
  has_one   :address
end
