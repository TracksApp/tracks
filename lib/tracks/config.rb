module Tracks
  
  class Config

    def self.auth_schemes
       SITE_CONFIG['authentication_schemes'] || []
    end
    
    def self.openid_enabled?
      auth_schemes.include?('open_id')
    end

    def self.cas_enabled?
      auth_schemes.include?('cas')
    end
    
    def self.prefered_auth?
      if SITE_CONFIG['prefered_auth']
        SITE_CONFIG['prefered_auth']
      else
        auth_schemes.first
      end
    end
    
  end
  
end
