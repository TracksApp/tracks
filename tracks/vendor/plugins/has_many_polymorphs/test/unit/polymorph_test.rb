require File.dirname(__FILE__) + '/../test_helper'

class PolymorphTest < Test::Unit::TestCase
  
  fixtures :cats, :bow_wows, :frogs, :wild_boars, :eaters_foodstuffs, :petfoods,
              :"aquatic/fish", :"aquatic/whales", :"aquatic/little_whale_pupils",
              :keep_your_enemies_close
  require 'beautiful_fight_relationship'  
  
  # to-do: finder queries on the collection
  #           order-mask column on the join table for polymorphic order
  #           rework load order so you could push and pop without ever loading the whole collection
  #           so that limit works in a sane way
      
  def setup
   @kibbles = Petfood.find(1)
   @bits = Petfood.find(2) 
   @shamu = Aquatic::Whale.find(1)
   @swimmy = Aquatic::Fish.find(1)
   @rover = Dog.find(1)
   @spot = Dog.find(2)
   @puma  = WildBoar.find(1)
   @chloe = Kitten.find(1)
   @alice = Kitten.find(2)
   @froggy = Frog.find(1)

   @join_count = EatersFoodstuff.count    
   @l = @kibbles.eaters.length  
   @m = @bits.eaters.count
  end
  
  def test_all_relationship_validities
    # q = []
    # ObjectSpace.each_object(Class){|c| q << c if c.ancestors.include? ActiveRecord::Base }
    # q.each{|c| puts "#{c.name}.reflect_on_all_associations.map &:check_validity! "}
    Petfood.reflect_on_all_associations.map &:check_validity! 
    Tabby.reflect_on_all_associations.map &:check_validity! 
    Kitten.reflect_on_all_associations.map &:check_validity! 
    Dog.reflect_on_all_associations.map &:check_validity! 
    Aquatic::Fish.reflect_on_all_associations.map &:check_validity! 
    EatersFoodstuff.reflect_on_all_associations.map &:check_validity! 
    WildBoar.reflect_on_all_associations.map &:check_validity! 
    Frog.reflect_on_all_associations.map &:check_validity! 
    Aquatic::Whale.reflect_on_all_associations.map &:check_validity! 
    Cat.reflect_on_all_associations.map &:check_validity! 
    Aquatic::PupilsWhale.reflect_on_all_associations.map &:check_validity! 
    BeautifulFightRelationship.reflect_on_all_associations.map &:check_validity! 
  end
  
  def test_assignment     
    assert @kibbles.eaters.blank?
    assert @kibbles.eaters.push(Cat.find_by_name('Chloe'))
    assert_equal @l += 1, @kibbles.eaters.count

    @kibbles.reload
    assert_equal @l, @kibbles.eaters.count
    
  end
  
  def test_duplicate_assignment
    # try to add a duplicate item
    @kibbles.eaters.push(@alice)
    assert @kibbles.eaters.include?(@alice)
    @kibbles.eaters.push(@alice)
    assert_equal @l + 1, @kibbles.eaters.count
    assert_equal @join_count + 1, EatersFoodstuff.count
    
    @kibbles.reload
    assert_equal @l + 1, @kibbles.eaters.count
    assert_equal @join_count + 1, EatersFoodstuff.count
  end
  
  def test_create_and_push
    assert @kibbles.eaters.push(@spot)  
    assert_equal @l += 1, @kibbles.eaters.count
    assert @kibbles.eaters << @rover
    assert @kibbles.eaters << Kitten.create(:name => "Miranda")
    assert_equal @l += 2, @kibbles.eaters.length

    @kibbles.reload
    assert_equal @l, @kibbles.eaters.length   
    
    # test that ids and new flags were set appropriately
    assert_not_nil @kibbles.eaters[0].id
    assert !@kibbles.eaters[1].new_record?
  end
 
  def test_reload
    assert @kibbles.reload
    assert @kibbles.eaters.reload
  end
 
  def test_add_join_record
    assert_equal Kitten, @chloe.class
    assert @join_record = EatersFoodstuff.new(:foodstuff_id => @bits.id, :eater_id => @chloe.id, :eater_type => @chloe.class.name ) 
    assert @join_record.save!
    assert @join_record.id
    assert_equal @join_count + 1, EatersFoodstuff.count

    # has the parent changed if we don't reload?
    assert_equal @m, @bits.eaters.count
    
    # if we do reload, is the new association there?
    # XXX no, because TestCase breaks reload. it works fine in the app.

    assert_equal Petfood, @bits.eaters.reload.class
    assert_equal @m + 1, @bits.eaters.count
    assert @bits.eaters.include?(@chloe)

#    puts "XXX #{EatersFoodstuff.count}"
   
  end
  
  def test_add_unsaved   
    # add an unsaved item
    assert @bits.eaters << Kitten.new(:name => "Bridget")
    assert_nil Kitten.find_by_name("Bridget")
    assert_equal @m + 1, @bits.eaters.count

    assert @bits.save
    @bits.reload
    assert_equal @m + 1, @bits.eaters.count
    
  end
  
  def test_self_reference
    assert @kibbles.eaters << @bits
    assert_equal @l += 1, @kibbles.eaters.count
    assert @kibbles.eaters.include?(@bits)
    @kibbles.reload
    assert @kibbles.foodstuffs_of_eaters.blank?
    
    @bits.reload
    assert @bits.foodstuffs_of_eaters.include?(@kibbles)
    assert_equal [@kibbles], @bits.foodstuffs_of_eaters
  end

  def test_remove
    assert @kibbles.eaters << @chloe
    @kibbles.reload
    assert @kibbles.eaters.delete(@kibbles.eaters[0])
    assert_equal @l, @kibbles.eaters.count
  end
  
  def test_destroy
    assert @kibbles.eaters.push(@chloe)
    @kibbles.reload
    assert @kibbles.eaters.length > 0
    assert @kibbles.eaters[0].destroy
    @kibbles.reload
    assert_equal @l, @kibbles.eaters.count
  end

  def test_clear
    @kibbles.eaters << [@chloe, @spot, @rover]
    @kibbles.reload
    assert_equal 3, @kibbles.eaters.clear.size
    assert @kibbles.eaters.blank?    
    @kibbles.reload    
    assert @kibbles.eaters.blank?    
    assert_equal 0, @kibbles.eaters.clear.size
  end
    
  def test_individual_collections
    assert @kibbles.eaters.push(@chloe)
    # check if individual collections work
    assert_equal @kibbles.eater_kittens.length, 1
    assert @kibbles.eater_dogs 
    assert 1, @rover.eaters_foodstuffs.count
  end
  
  def test_invididual_collections_push
    assert_equal [@chloe], (@kibbles.eater_kittens << @chloe)
    @kibbles.reload
    assert @kibbles.eaters.include?(@chloe)
    assert @kibbles.eater_kittens.include?(@chloe)
    assert !@kibbles.eater_dogs.include?(@chloe)
  end

  def test_invididual_collections_delete
    @kibbles.eaters << [@chloe, @spot, @rover]
    @kibbles.reload
    assert_equal [@chloe], @kibbles.eater_kittens.delete(@chloe)
    assert @kibbles.eater_kittens.empty?
    assert  !@kibbles.eater_kittens.delete(@chloe)
    
    @kibbles.reload    
    assert @kibbles.eater_kittens.empty?
    assert @kibbles.eater_dogs.include?(@spot)
  end
  
  def test_invididual_collections_clear
    @kibbles.eaters << [@chloe, @spot, @rover]
    @kibbles.reload
    assert_equal [@chloe], @kibbles.eater_kittens.clear
    assert @kibbles.eater_kittens.empty?    
    assert_equal 2, @kibbles.eaters.size
    @kibbles.reload    
    assert @kibbles.eater_kittens.empty?    
    assert_equal 2, @kibbles.eaters.size
    assert !@kibbles.eater_kittens.include?(@chloe)
    assert !@kibbles.eaters.include?(@chloe)
  end
  
  def test_childrens_individual_collections
    assert Cat.find_by_name('Chloe').eaters_foodstuffs
    assert @kibbles.eaters_foodstuffs
  end
  
  def test_self_referential_join_tables
    # check that the self-reference join tables go the right ways
    assert_equal @l, @kibbles.eaters_foodstuffs.count
    assert_equal @kibbles.eaters_foodstuffs.count, @kibbles.eaters_foodstuffs_as_child.count
  end

  def test_dependent
    assert @kibbles.eaters << @chloe
    @kibbles.reload
 
    # delete ourself and see if :dependent was obeyed
    dependent_rows = @kibbles.eaters_foodstuffs
    assert_equal dependent_rows.length, @kibbles.eaters.count
    @join_count = EatersFoodstuff.count
    
    @kibbles.destroy
    assert_equal @join_count - dependent_rows.length, EatersFoodstuff.count
    assert_equal 0, EatersFoodstuff.find(:all, :conditions => ['foodstuff_id = ?', 1] ).length
  end
  
  def test_normal_callbacks
    assert @rover.respond_to?(:after_initialize)
    assert @rover.respond_to?(:after_find)
    
    assert @rover.after_initialize_test
    assert @rover.after_find_test
  end    
  
  def test_our_callbacks
    assert 0, @bits.eaters.count
    assert @bits.eaters.push(@rover)
    @bits.save
    
#    puts "Testing callbacks."
    @bits2 = Petfood.find_by_name("Bits")
    @bits.reload
    
    assert rover = @bits2.eaters.select { |x| x.name == "Rover" }[0]
    assert rover.after_initialize_test
    assert rover.after_find_test
#    puts "Done."
    
  end

  def test_number_of_join_records
    assert EatersFoodstuff.create(:foodstuff_id => 1, :eater_id => 1, :eater_type => "Cat")
    @join_count = EatersFoodstuff.count    
    assert @join_count > 0
  end
  
  def test_number_of_regular_records
    dogs = Dog.count
    assert Dog.new(:name => "Auggie").save!
    assert dogs + 1, Dog.count
  end

  def test_attributes_come_through_when_child_has_underscore_in_table_name
    @join_record = EatersFoodstuff.new(:foodstuff_id => @bits.id, :eater_id =>  @puma.id, :eater_type => @puma.class.name) 
    @join_record.save!
    @bits.eaters.reload

    assert_equal 'Puma', @puma.name
    assert_equal 'Puma', @bits.eaters.first.name
  end
  
  def test_before_save_on_join_table_is_not_clobbered_by_sti_base_class_fix
    assert @kibbles.eaters << @chloe
    assert_equal 3, @kibbles.eaters_foodstuffs.first.some_attribute
  end
  
  def test_creating_namespaced_relationship
    assert @shamu.aquatic_pupils.empty?
    @shamu.aquatic_pupils << @swimmy
    assert_equal 1, @shamu.aquatic_pupils.length
    @shamu.reload
    assert_equal 1, @shamu.aquatic_pupils.length
  end
  

  def test_namespaced_polymorphic_collection
    @shamu.aquatic_pupils << @swimmy
    assert @shamu.aquatic_pupils.include?(@swimmy)
    @shamu.reload
    assert @shamu.aquatic_pupils.include?(@swimmy)

    @shamu.aquatic_pupils << @spot
    assert @shamu.dogs.include?(@spot)
    assert @shamu.aquatic_pupils.include?(@swimmy)
    assert_equal @swimmy, @shamu.aquatic_fish.first
    assert_equal 10, @shamu.aquatic_fish.first.speed
  end
  
  def test_deleting_namespaced_relationship    
    @shamu.aquatic_pupils << @swimmy
    @shamu.aquatic_pupils << @spot
    
    @shamu.reload
    @shamu.aquatic_pupils.delete @spot
    assert !@shamu.dogs.include?(@spot)
    assert !@shamu.aquatic_pupils.include?(@spot)
    assert_equal 1, @shamu.aquatic_pupils.length
  end
  
  def test_unrenamed_parent_of_namespaced_child
    @shamu.aquatic_pupils << @swimmy
    assert_equal [@shamu], @swimmy.whales
  end
  
  def test_empty_double_collections
    assert @puma.enemies.empty?
    assert @froggy.protectors.empty?
    assert @alice.enemies.empty?
    assert @spot.protectors.empty?
    assert @alice.beautiful_fight_relationships_as_enemy.empty?
    assert @alice.beautiful_fight_relationships_as_protector.empty?
    assert @alice.beautiful_fight_relationships.empty?    
  end
  
  def test_double_collection_assignment
    @alice.enemies << @spot
    @alice.reload
    @spot.reload
    assert @spot.protectors.include?(@alice)
    assert @alice.enemies.include?(@spot)
    assert !@alice.protectors.include?(@alice)
    assert_equal 1, @alice.beautiful_fight_relationships_as_protector.size
    assert_equal 0, @alice.beautiful_fight_relationships_as_enemy.size
    assert_equal 1, @alice.beautiful_fight_relationships.size
    
    # self reference
    assert_equal 1, @alice.enemies.length
    @alice.enemies.push @alice
    assert @alice.enemies.include?(@alice)
    assert_equal 2, @alice.enemies.length    
    @alice.reload
    assert_equal 2, @alice.beautiful_fight_relationships_as_protector.size
    assert_equal 1, @alice.beautiful_fight_relationships_as_enemy.size
    assert_equal 3, @alice.beautiful_fight_relationships.size
  end
  
  def test_double_collection_deletion
    @alice.enemies << @spot
    @alice.reload
    assert @alice.enemies.include?(@spot)
    @alice.enemies.delete(@spot)
    assert !@alice.enemies.include?(@spot)
    assert @alice.enemies.empty?
    @alice.reload
    assert !@alice.enemies.include?(@spot)
    assert @alice.enemies.empty?
    assert_equal 0, @alice.beautiful_fight_relationships.size
  end
 
  def test_double_collection_deletion_from_opposite_side
    @alice.protectors << @puma
    @alice.reload
    assert @alice.protectors.include?(@puma)
    @alice.protectors.delete(@puma)
    assert !@alice.protectors.include?(@puma)
    assert @alice.protectors.empty?
    @alice.reload
    assert !@alice.protectors.include?(@puma)
    assert @alice.protectors.empty?
    assert_equal 0, @alice.beautiful_fight_relationships.size
  end
 
  def test_individual_collections_created_for_double_relationship
    assert @alice.dogs.empty?
    @alice.enemies << @spot

    assert @alice.enemies.include?(@spot)
    assert !@alice.kittens.include?(@alice)    

    assert !@alice.dogs.include?(@spot)    
    @alice.reload
    assert @alice.dogs.include?(@spot)    
    assert !WildBoar.find(@alice.id).dogs.include?(@spot) # make sure the parent type is checked
  end

  def test_individual_collections_created_for_double_relationship_from_opposite_side
    assert @alice.wild_boars.empty?
    @alice.protectors << @puma

    assert @alice.protectors.include?(@puma)
    assert !@alice.wild_boars.include?(@puma)    
    @alice.reload
    assert @alice.wild_boars.include?(@puma)    
    
    assert !Dog.find(@alice.id).wild_boars.include?(@puma) # make sure the parent type is checked
  end
  
  def test_self_referential_individual_collections_created_for_double_relationship
    @alice.enemies << @alice
    @alice.reload
    assert @alice.enemy_kittens.include?(@alice)
    assert @alice.protector_kittens.include?(@alice)
    assert @alice.kittens.include?(@alice)
    assert_equal 2, @alice.kittens.size

    @alice.enemies << (@chloe =  Kitten.find_by_name('Chloe'))
    @alice.reload
    assert @alice.enemy_kittens.include?(@chloe)
    assert !@alice.protector_kittens.include?(@chloe)
    assert @alice.kittens.include?(@chloe)
    assert_equal 3, @alice.kittens.size    
  end
    
  def test_child_of_polymorphic_join_can_reach_parent
    @alice.enemies << @spot    
    @alice.reload
    assert @spot.protectors.include?(@alice)
  end
  
  def test_double_collection_deletion_from_child_polymorphic_join
    @alice.enemies << @spot
    @spot.protectors.delete(@alice)
    assert !@spot.protectors.include?(@alice)
    @alice.reload
    assert !@alice.enemies.include?(@spot)
    BeautifulFightRelationship.create(:protector_id => 2, :protector_type => "Dog", :enemy_id => @spot.id, :enemy_type => @spot.class.name)
    @alice.enemies << @spot
    @spot.protectors.delete(@alice)
    assert !@spot.protectors.include?(@alice)
  end

  def test_hmp_passed_block_manipulates_proxy_class
    assert_equal "result", @shamu.aquatic_pupils.blow
    assert_raises(NoMethodError) { @kibbles.eaters.blow }
  end

  def test_collection_query_on_unsaved_record
    assert Dog.new.enemies.empty?
    assert Dog.new.foodstuffs_of_eaters.empty?
  end
 
  def test_double_invididual_collections_push
    assert_equal [@chloe], (@spot.protector_kittens << @chloe)
    @spot.reload
    assert @spot.protectors.include?(@chloe)
    assert @spot.protector_kittens.include?(@chloe)
    assert !@spot.protector_dogs.include?(@chloe)
 
    assert_equal [@froggy], (@spot.frogs << @froggy)
    @spot.reload
    assert @spot.enemies.include?(@froggy)
    assert @spot.frogs.include?(@froggy)
    assert !@spot.enemy_dogs.include?(@froggy)
  end

  def test_double_invididual_collections_delete
    @spot.protectors << [@chloe, @puma]
    @spot.reload
    assert_equal [@chloe], @spot.protector_kittens.delete(@chloe)
    assert @spot.protector_kittens.empty?
    assert  !@spot.protector_kittens.delete(@chloe)
    
    @spot.reload    
    assert @spot.protector_kittens.empty?
    assert @spot.wild_boars.include?(@puma)
  end
  
  def test_double_invididual_collections_clear
    @spot.protectors << [@chloe, @puma, @alice]
    @spot.reload
    assert_equal [@chloe, @alice], @spot.protector_kittens.clear.sort_by(&:id)
    assert @spot.protector_kittens.empty?    
    assert_equal 1, @spot.protectors.size
    @spot.reload    
    assert @spot.protector_kittens.empty?    
    assert_equal 1, @spot.protectors.size
    assert !@spot.protector_kittens.include?(@chloe)
    assert !@spot.protectors.include?(@chloe)
    assert !@spot.protector_kittens.include?(@alice)
    assert !@spot.protectors.include?(@alice)
  end 


end
