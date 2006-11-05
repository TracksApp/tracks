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
  module ControllerMethods
    def self.included(controller)
      controller.class_eval do
        verify :method => :post, :only => :begin, :params => :openid_url, :redirect_to => { :action => 'index' },
        :add_flash => { :error => "Enter an Identity URL to verify." }
        verify :method => :get, :only => :complete, :redirect_to => { :action => 'index' }
        before_filter  :begin_open_id_auth,    :only => :begin
        before_filter  :complete_open_id_auth, :only => :complete
        attr_reader    :open_id_response
        attr_reader    :open_id_fields
        cattr_accessor :open_id_consumer_options
      end
    end

    protected
      def open_id_consumer
        @open_id_consumer ||= OpenID::Consumer.new(
          session[:openid_session] ||= {}, 
          ActiveRecordOpenIdStore.new)
      end

      def begin_open_id_auth
        @open_id_response = open_id_consumer.begin(params[:openid_url])
        add_sreg_params!(@open_id_response) if @open_id_response.status == OpenID::SUCCESS
      end

      def complete_open_id_auth
        @open_id_response = open_id_consumer.complete(params)
        return unless open_id_response.status == OpenID::SUCCESS

        @open_id_fields   = open_id_response.extension_response('sreg')
        logger.debug "***************** sreg params ***************"
        logger.debug @open_id_fields.inspect
        logger.debug "***************** sreg params ***************"
      end

      def add_sreg_params!(openid_response)
        open_id_consumer_options.keys.inject({}) do |params, key|
          value = open_id_consumer_options[key]
          value = value.collect { |v| v.to_s.strip } * ',' if value.respond_to?(:collect)
          openid_response.add_extension_arg('sreg', key.to_s, value.to_s)
        end
      end
  end
end
