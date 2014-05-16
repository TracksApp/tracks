require 'openssl'

class MailgunController < ApplicationController

  skip_before_filter :login_required, :only => [:mailgun]
  before_filter :verify, :only => [:mailgun]
  protect_from_forgery with: :null_session

  def mailgun
    unless params.include? 'body-mime'
      Rails.logger.info "Cannot process Mailgun request, no body-mime sent"
      render_failure "Unacceptable body-mime", 406
      return
    end

    todo = MessageGateway.receive(params['body-mime'])
    if todo
      render :xml => todo.to_xml( *todo_xml_params )
    else
      render_failure "Todo not saved", 406
    end
  end

  private

  def verify
    unless params['signature'] == OpenSSL::HMAC.hexdigest(
            OpenSSL::Digest.new('sha256'),
            SITE_CONFIG['mailgun_api_key'],
            '%s%s' % [params['timestamp'], params['token']]
         )
      Rails.logger.info "Cannot verify Mailgun signature"
      render_failure "Access denied", 406
      return
    end
  end

end
