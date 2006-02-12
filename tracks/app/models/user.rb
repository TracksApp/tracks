require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  has_many :contexts, :order => "position ASC"
  has_many :projects, :order => "position ASC"
  has_many :todos, :order => "completed DESC"
  has_many :notes, :order => "created_at DESC"
  
  serialize :preferences

  attr_protected :is_admin

  def self.authenticate(login, pass)
    find_first(["login = ? AND password = ?", login, sha1(pass)])
  end

  def change_password(pass)
    update_attribute "password", self.class.sha1(pass)
  end

protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("change-me--#{pass}--")
  end

  before_create :crypt_password

  def crypt_password
    write_attribute("password", self.class.sha1(password)) if password == @password_confirmation
    write_attribute("word", self.class.sha1(login + word))
  end

  validates_length_of :password, :within => 5..40
  validates_length_of :login, :within => 3..80
  validates_presence_of :password, :login, :word
  validates_uniqueness_of :login, :on => :create
  validates_confirmation_of :password, :on => :create
  
end
