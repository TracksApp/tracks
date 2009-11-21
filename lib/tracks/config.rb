module Tracks
  class Config
    def self.salt
       SITE_CONFIG['salt']
    end

    def self.auth_schemes
       SITE_CONFIG['authentication_schemes'] || []
    end
    
    def self.openid_enabled?
      auth_schemes.include?('open_id')
    end

    def self.cas_enabled?
      auth_schemes.include?('cas')
    end
  end
end