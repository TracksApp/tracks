require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :contexts, :order => "position ASC"
  has_many :projects, :order => "position ASC"
  has_many :todos, :order => "completed_at DESC, created_at DESC"
  has_many :notes, :order => "created_at DESC"
  has_one :preference
  
  attr_protected :is_admin

  def self.authenticate(login, pass)
    candidate = find(:first, :conditions => ["login = ?", login])
    return nil if candidate.nil?
    if candidate.auth_type == 'database'
      return candidate if candidate.password == sha1(pass)
    elsif candidate.auth_type == 'ldap' && Tracks::Config.auth_schemes.include?('ldap')
      return candidate if SimpleLdapAuthenticator.valid?(login, pass)
    end
    nil
  end
  
  def self.find_admin
    find_first([ "is_admin = ?", true ])    
  end
  
  def display_name
    if first_name.blank? && last_name.blank?
      return login
    elsif first_name.blank?
      return last_name
    elsif last_name.blank?
      return first_name
    end
    "#{first_name} #{last_name}"
  end
  
  def change_password(pass,pass_confirm)
    self.password = pass
    self.password_confirmation = pass_confirm
  end

  def crypt_word
    write_attribute("word", self.class.sha1(login + Time.now.to_i.to_s + rand.to_s))
  end

protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{Tracks::Config.salt}--#{pass}--")
  end

  before_create :crypt_password, :crypt_word
  before_update :crypt_password
  
  def crypt_password
    write_attribute("password", self.class.sha1(password)) if password == @password_confirmation
  end
  
  def password_required?
    auth_type == 'database'
  end
    
  validates_presence_of :login
  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password  
  validates_length_of :login, :within => 3..80
  validates_uniqueness_of :login, :on => :create
  validates_inclusion_of :auth_type, :in => Tracks::Config.auth_schemes, :message=>"not a valid authentication type"
  validates_presence_of :open_id_url, :if => Proc.new{|user| user.auth_type == 'open_id'}
end
