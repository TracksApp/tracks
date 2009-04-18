require 'digest/sha1'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  has_many :contexts,
           :order => 'position ASC',
           :dependent => :delete_all do
             def find_by_params(params)
               find(params['id'] || params['context_id']) || nil
             end
           end
  has_many :projects,
           :order => 'projects.position ASC',
           :dependent => :delete_all do
              def find_by_params(params)
                find(params['id'] || params['project_id'])
              end
              def update_positions(project_ids)
                project_ids.each_with_index do |id, position|
                  project = self.detect { |p| p.id == id.to_i }
                  raise "Project id #{id} not associated with user id #{@user.id}." if project.nil?
                  project.update_attribute(:position, position + 1)
                end
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
              def actionize(user_id, scope_conditions = {})
                @state = scope_conditions[:state]
                query_state = ""
                query_state = "AND project.state = '" + @state +"' "if @state
                projects = Project.find_by_sql([
                    "SELECT project.id, count(todo.id) as p_count " +
                      "FROM projects as project " +
                      "LEFT OUTER JOIN todos as todo ON todo.project_id = project.id "+
                      "WHERE project.user_id = ? AND NOT (todo.state='completed') " +
                      query_state +
                      " GROUP BY project.id ORDER by p_count DESC",user_id])
                self.update_positions(projects.map{ |p| p.id })
                projects = find(:all, :conditions => scope_conditions)
                return projects
              end
            end
  has_many :active_projects,
           :class_name => 'Project',
           :order => 'projects.position ASC',
           :conditions => [ 'state = ?', 'active' ]
  has_many :active_contexts,
           :class_name => 'Context',
           :order => 'position ASC',
           :conditions => [ 'hide = ?', false ]
  has_many :todos,
           :order => 'todos.completed_at DESC, todos.created_at DESC',
           :dependent => :delete_all
  has_many :project_hidden_todos,
           :conditions => ['(state = ? OR state = ?)', 'project_hidden', 'active']
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
  has_many :completed_todos,
           :class_name => 'Todo',
           :conditions => ['todos.state = ? AND NOT(todos.completed_at IS NULL)', 'completed'],
           :order => 'todos.completed_at DESC',
           :include => [ :project, :context ] do
             def completed_within( date )
               reject { |x| x.completed_at < date }
             end

             def completed_more_than( date )
               reject { |x| x.completed_at > date }
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
    return candidate if candidate.auth_type == 'database' && candidate.crypted_password == sha1(pass)
    if Tracks::Config.auth_schemes.include?('ldap')
      return candidate if candidate.auth_type == 'ldap' && SimpleLdapAuthenticator.valid?(login, pass)
    end
    return nil
  end
  
  def self.find_by_open_id_url(raw_identity_url)
    normalized_open_id_url = OpenIdAuthentication.normalize_url(raw_identity_url)
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
    self.token = Digest::SHA1.hexdigest "#{Time.now.to_i}#{rand}"
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

protected

  def self.sha1(s)
    Digest::SHA1.hexdigest("#{Tracks::Config.salt}--#{s}--")
  end
  
  def crypt_password
    return if password.blank?
    write_attribute("crypted_password", self.class.sha1(password)) if password == password_confirmation
  end
  
  def password_required?
    auth_type == 'database' && crypted_password.blank? || !password.blank?
  end
  
  def using_openid?
    auth_type == 'open_id'
  end
  
  def password_matches?(pass)
    crypted_password == sha1(pass)
  end
  
  def normalize_open_id_url
    return if open_id_url.nil?
    self.open_id_url = OpenIdAuthentication.normalize_url(open_id_url)
  end
end
