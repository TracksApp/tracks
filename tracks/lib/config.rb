module Tracks
  
  class Config
    
    def self.salt
      SALT
    end

    def self.auth_schemes
      AUTHENTICATION_SCHEMES
    end
    
    def self.openid_enabled?
      auth_schemes.include?('open_id')
    end
    
    
  end
  
end