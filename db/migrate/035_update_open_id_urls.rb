class UpdateOpenIdUrls < ActiveRecord::Migration

  class User < ActiveRecord::Base
    
    def normalize_open_id_url
      return if open_id_url.nil?
      self.open_id_url = self.class.normalize_open_id_url(open_id_url)
    end
    
    def self.normalize_open_id_url(raw_open_id_url)
      normalized = raw_open_id_url
      normalized = "http://#{raw_open_id_url}" unless raw_open_id_url =~ /\:\/\//
      normalized.downcase.chomp('/')
    end
    
  end

  def self.up
    User.all.each do |user|
      original = user.open_id_url
      user.normalize_open_id_url
      say "#{original} -> #{user.open_id_url}"
      user.save! unless user.open_id_url == original
    end
  end

  def self.down
  end
end
