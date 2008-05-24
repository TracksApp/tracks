class CitationsItem < ActiveRecord::Base
  belongs_to :citation
  belongs_to :item, :polymorphic => true
end
