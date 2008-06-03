# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

begin
  require_gem "ruby-openid", ">= 1.0"
rescue LoadError
  require "openid"
end

module OpenIdConsumer
  class ActiveRecordOpenIdStore < OpenID::Store
    def get_auth_key
      setting = Setting.find_by_setting 'auth_key'
      if setting.nil?
        auth_key = OpenID::Util.random_string(20)
        setting = Setting.create :setting => 'auth_key', :value => auth_key
      end
      setting.value
    end

    def store_association(server_url, assoc)
      remove_association(server_url, assoc.handle)    
      Association.create(:server_url => server_url,
                         :handle     => assoc.handle,
                         :secret     => assoc.secret,
                         :issued     => assoc.issued,
                         :lifetime   => assoc.lifetime,
                         :assoc_type => assoc.assoc_type)
    end

    def get_association(server_url, handle=nil)
      assocs = handle.blank? ? 
        Association.find_all_by_server_url(server_url) :
        Association.find_all_by_server_url_and_handle(server_url, handle)
  
      assocs.reverse.each do |assoc|
        a = assoc.from_record    
        if a.expired?
          assoc.destroy
        else
          return a
        end
      end if assocs.any?
  
      return nil
    end

    def remove_association(server_url, handle)
      assoc = Association.find_by_server_url_and_handle(server_url, handle)
      unless assoc.nil?
        assoc.destroy
        return true
      end
      false
    end

    def store_nonce(nonce)
      use_nonce(nonce)
      Nonce.create :nonce => nonce, :created => Time.now.to_i
    end

    def use_nonce(nonce)
      nonce = Nonce.find_by_nonce(nonce)
      return false if nonce.nil?
    
      age = Time.now.to_i - nonce.created
      nonce.destroy

      age < 6.hours # max nonce age of 6 hours
    end
  
    def dumb?
      false
    end

    # not part of the api, but useful
    def gc
      now = Time.now.to_i

      # remove old nonces
      nonces = Nonce.find(:all)
      nonces.each {|n| n.destroy if now - n.created > 6.hours} unless nonces.nil?

      # remove expired assocs
      assocs = Association.find(:all)
      assocs.each { |a| a.destroy if a.from_record.expired? } unless assocs.nil?
    end
  end
end
