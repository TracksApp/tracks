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

class <%= controller_class_name %>Controller < ApplicationController
  open_id_consumer :required => [:email, :nickname], :optional => [:fullname, :dob, :gender, :country]

  def index
    @title = 'Welcome'
  end

  def begin
    # If the URL was unusable (either because of network conditions,
    # a server error, or that the response returned was not an OpenID
    # identity page), the library will return HTTP_FAILURE or PARSE_ERROR.
    # Let the user know that the URL is unusable.
    case open_id_response.status
      when OpenID::SUCCESS
        # The URL was a valid identity URL. Now we just need to send a redirect
        # to the server using the redirect_url the library created for us.
    
        # redirect to the server
        redirect_to open_id_response.redirect_url((request.protocol + request.host_with_port + '/'), url_for(:action => 'complete'))
      else
        flash[:error] = "Unable to find openid server for <q>#{params[:openid_url]}</q>"
        render :action => :index
    end
  end

  def complete
    case open_id_response.status
      when OpenID::FAILURE
        # In the case of failure, if info is non-nil, it is the
        # URL that we were verifying. We include it in the error
        # message to help the user figure out what happened.
        if open_id_response.identity_url
          flash[:message] = "Verification of #{open_id_response.identity_url} failed. "
        else
          flash[:message] = "Verification failed. "
        end
        flash[:message] += open_id_response.msg.to_s
    
      when OpenID::SUCCESS
        # Success means that the transaction completed without
        # error. If info is nil, it means that the user cancelled
        # the verification.
        flash[:message] = "You have successfully verified #{open_id_response.identity_url} as your identity."
        if open_id_fields.any?
          flash[:message] << "<hr /> With simple registration fields:<br/>"
          open_id_fields.each {|k,v| flash[:message] << "<br /><b>#{k}</b>: #{v}"}
        end
    
      when OpenID::CANCEL
        flash[:message] = "Verification cancelled."
    
      else
        flash[:message] = "Unknown response status: #{open_id_response.status}"
    end
    redirect_to :action => 'index'
  end
end
