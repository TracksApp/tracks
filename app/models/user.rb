require 'digest/sha1'
require 'bcrypt'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_protected :is_admin # don't allow mass-assignment for this

  has_many :contexts,
           :order => 'position ASC',
           :dependent => :delete_all do
             def find_by_params(params)
               find(params['id'] || params['context_id']) || nil
             end
             def update_positions(context_ids)
                context_ids.each_with_index {|id, position|
                  context = self.detect { |c| c.id == id.to_i }
                  raise I18n.t('models.user.error_context_not_associated', :context => id, :user => @user.id) if context.nil?
                  context.update_attribute(:position, position + 1)
                }
              end
           end
  has_many :projects,
           :order => 'projects.position ASC',
           :dependent => :delete_all do
              def find_by_params(params)
                find(params['id'] || params['project_id'])
              end
              def update_positions(project_ids)
                project_ids.each_with_index {|id, position|
                  project = self.detect { |p| p.id == id.to_i }
                  raise I18n.t('models.user.error_project_not_associated', :project => id, :user => @user.id) if project.nil?
                  project.update_attribute(:position, position + 1)
                }
              end
              def projects_in_state_by_position(state)
                  self.sort{ |a,b| a.position <=> b.position }.select{ |p| p.state == state }
              end
              def next_from(project)
                self.offset_from(project, 1)
              end
              def previous_from(project)
                self.offset_from(project, -1)
              end
              def offset_from(project, offset)
                projects = self.projects_in_state_by_position(project.state)
                position = projects.index(project)
                return nil if position == 0 && offset < 0
                projects.at( position + offset)
              end
              def cache_note_counts
                project_note_counts = Note.count(:group => 'project_id')
                self.each do |project|
                  project.cached_note_count = project_note_counts[project.id] || 0
                end
              end
              def alphabetize(scope_conditions = {})
                projects = find(:all, :conditions => scope_conditions)
                projects.sort!{ |x,y| x.name.downcase <=> y.name.downcase }
                self.update_positions(projects.map{ |p| p.id })
                return projects
              end
              def actionize(scope_conditions = {})
                todos_in_project = find(:all, :conditions => scope_conditions, :include => [:todos])
                todos_in_project.sort!{ |x, y| -(x.todos.active.count <=> y.todos.active.count) }
                todos_in_project.reject{ |p| p.todos.active.count > 0 }
                sorted_project_ids = todos_in_project.map {|p| p.id}
                
                all_project_ids = find(:all).map {|p| p.id}
                other_project_ids = all_project_ids - sorted_project_ids
                
                update_positions(sorted_project_ids + other_project_ids)

                return find(:all, :conditions => scope_conditions)
              end
            end
  has_many :todos,
           :order => 'todos.completed_at DESC, todos.created_at DESC',
           :dependent => :delete_all
  has_many :recurring_todos,
           :order => 'recurring_todos.completed_at DESC, recurring_todos.created_at DESC',
           :dependent => :delete_all
  has_many :deferred_todos,
           :class_name => 'Todo',
           :conditions => [ 'state = ?', 'deferred' ],
           :order => 'show_from ASC, todos.created_at DESC' do
              def find_and_activate_ready
                find(:all, :conditions => ['show_from <= ?', Time.zone.now ]).collect { |t| t.activate! }
              end
           end
  has_many :notes, :order => "created_at DESC", :dependent => :delete_all
  has_one :preference, :dependent => :destroy
  
  attr_protected :is_admin

  validates_presence_of :login
  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :within => 5..40, :if => :password_required?
  validates_presence_of :password_confirmation, :if => :password_required?
  validates_confirmation_of :password  
  validates_length_of :login, :within => 3..80
  validates_uniqueness_of :login, :on => :create
  validates_presence_of :open_id_url, :if => :using_openid?

  before_create :crypt_password, :generate_token
  before_update :crypt_password
  before_save :normalize_open_id_url

  #for will_paginate plugin
  cattr_accessor :per_page
  @@per_page = 5
  
  def validate
    unless Tracks::Config.auth_schemes.include?(auth_type)
      errors.add("auth_type", "not a valid authentication type (#{auth_type})")
    end
  end

  alias_method :prefs, :preference

  def self.authenticate(login, pass)
    return nil if login.blank?
    candidate = find(:first, :conditions => ["login = ?", login])
    return nil if candidate.nil?

    if Tracks::Config.auth_schemes.include?('database')
      return candidate if candidate.auth_type == 'database' and
        candidate.password_matches? pass
    end
    
    if Tracks::Config.auth_schemes.include?('ldap')
      return candidate if candidate.auth_type == 'ldap' && SimpleLdapAuthenticator.valid?(login, pass)
    end
    
    if Tracks::Config.auth_schemes.include?('cas')
      # because we can not auth them with out thier real password we have to settle for this
      return candidate if candidate.auth_type.eql?("cas")
    end
    
    if Tracks::Config.auth_schemes.include?('open_id')
      # hope the user enters the correct data
      return candidate if candidate.auth_type.eql?("open_id")
    end
    
    return nil
  end
  
  def self.find_by_open_id_url(raw_identity_url)
    normalized_open_id_url = OpenIdAuthentication.normalize_identifier(raw_identity_url)
    find(:first, :conditions => ['open_id_url = ?', normalized_open_id_url])
  end
  
  def self.no_users_yet?
    count == 0
  end
  
  def self.find_admin
    find(:first, :conditions => [ "is_admin = ?", true ])    
  end
  
  def to_param
    login
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
    save!
  end
  
  def time
    Time.now.in_time_zone(prefs.time_zone)
  end

  def date
    time.midnight
  end
  
  def at_midnight(date)
    return ActiveSupport::TimeZone[prefs.time_zone].local(date.year, date.month, date.day, 0, 0, 0)
  end
  
  def generate_token
    self.token = self.class.sha1 "#{Time.now.to_i}#{rand}"
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token ||= self.class.sha1("#{login}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has a password hashed using SHA-1.
  def uses_deprecated_password?
    crypted_password =~ /^[a-f0-9]{40}$/i
  end

  def password_matches?(pass)
    if uses_deprecated_password?
      crypted_password == User.sha1(pass)
    else
      BCrypt::Password.new(crypted_password) == pass
    end
  end

protected

  def self.salted(s)
    "#{Tracks::Config.salt}--#{s}--"
  end

  def self.sha1(s)
    Digest::SHA1.hexdigest salted s
  end

  def self.hash(s)
    BCrypt::Password.create s
  end
  
  def crypt_password
    return if password.blank?
    write_attribute("crypted_password", self.class.hash(password)) if password == password_confirmation
  end
  
  def password_required?
    auth_type == 'database' && crypted_password.blank? || !password.blank?
  end
  
  def using_openid?
    auth_type == 'open_id'
  end
  
  def normalize_open_id_url
    return if open_id_url.nil?
    
    # fixup empty url value
    if open_id_url.empty?
      self.open_id_url = nil
      return
    end
    
    self.open_id_url = OpenIdAuthentication.normalize_identifier(open_id_url)
  end
end
