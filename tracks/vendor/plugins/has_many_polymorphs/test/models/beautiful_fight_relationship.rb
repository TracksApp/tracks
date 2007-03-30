
class BeautifulFightRelationship < ActiveRecord::Base
  set_table_name 'keep_your_enemies_close'

  belongs_to :enemy, :polymorphic => true
  belongs_to :protector, :polymorphic => true
  # polymorphic relationships with column names different from the relationship name
  # are not supported by Rails
  
  acts_as_double_polymorphic_join :enemies => [:dogs, :kittens, :frogs], 
                                                      :protectors =>  [:wild_boars, :kittens, :"aquatic/fish", :dogs]
end

