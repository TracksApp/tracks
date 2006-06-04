require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  has_many :contexts, :order => "position ASC"
  has_many :projects, :order => "position ASC"
  has_many :todos, :order => "completed DESC, created_at DESC"
  has_many :notes, :order => "created_at DESC"
  
  serialize :preferences

  attr_protected :is_admin

  def self.authenticate(login, pass)
    find_first(["login = ? AND password = ?", login, sha1(pass)])
  end
  
  def self.find_admin
    find_first([ "is_admin = ?", true ])    
  end

  def change_password(pass,pass_confirm)
    self.password = pass
    self.password_confirmation = pass_confirm
  end

protected

  def self.sha1(pass)
    # SALT is set in RAILS_ROOT/config/environment.rb
    Digest::SHA1.hexdigest("#{SALT}--#{pass}--")
  end

  before_create :crypt_password_and_word
  before_update :crypt_password_and_word
  
  def crypt_password_and_word
    write_attribute("password", self.class.sha1(password)) if password == @password_confirmation
    write_attribute("word", self.class.sha1(login + Time.now.to_i.to_s + rand.to_s))
  end
  
  validates_presence_of :password, :login
  validates_length_of :password, :within => 5..40
  validates_confirmation_of :password  
  validates_length_of :login, :within => 3..80
  validates_uniqueness_of :login, :on => :create
  
end
