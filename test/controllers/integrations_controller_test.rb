require 'test_helper'

class IntegrationsControllerTest < ActionController::TestCase

  def setup
  end
  
  def test_page_load
    login_as(:admin_user)
    get :rest_api
    assert_response :success
  end
  
  def test_cloudmailin_integration_success
    SITE_CONFIG['cloudmailin'] = "123456789"
    SITE_CONFIG['email_dispatch'] = 'from'
    post :cloudmailin, {
      "html"=>"",
      "plain"=>"asdasd",
      "x_to_header"=>"[\"81496ecea21032d35a7a@cloudmailin.net\"]",
      "disposable"=>"",
      "from"=>"5555555555@tmomail.net",
      "signature"=>"e85e908fb893394762047c21e54ce248",
      "to"=>"<123123@cloudmailin.net>",
      "subject"=>"asd",
      "x_cc_header"=>"",
      "message"=>"Received: from VMBX103.ihostexchange.net ([192.168.3.3]) by\r\n HUB103.ihostexchange.net ([66.46.182.53]) with mapi; Wed, 5 Oct 2011 17:12:44\r\n -0400\r\nFrom: SMS User <5555555555@tmomail.net>\r\nTo: Tracks <123123@cloudmailin.net>\r\nDate: Wed, 5 Oct 2011 17:12:43 -0400\r\nSubject: asd\r\nThread-Topic: asd\r\nThread-Index: AcyDo4aig2wghvcsTAOkleWqi4t/FQ==\r\nMessage-ID: <7D7CB176-7559-4997-A301-8DF9726264C7@tmomail.net>\r\nAccept-Language: de-DE, en-US\r\nContent-Language: en-US\r\nX-MS-Has-Attach:\r\nX-MS-TNEF-Correlator:\r\nacceptlanguage: de-DE, en-US\r\nContent-Type: text/plain; charset=\"us-ascii\"\r\nContent-Transfer-Encoding: quoted-printable\r\nMIME-Version: 1.0\r\n\r\nasdasd\r\n"
    }
    
    assert_response :success
  end
  
  def test_cloudmailin_integration_invalid_signature
    SITE_CONFIG['cloudmailin'] = "12345678901234567890"
    post :cloudmailin, {
      "html"=>"",
      "plain"=>"asdasd",
      "x_to_header"=>"[\"81496ecea21032d35a7a@cloudmailin.net\"]",
      "disposable"=>"",
      "from"=>"5555555555@tmomail.net",
      "signature"=>"e85e908fb893394762047c21e54ce248",
      "to"=>"<123123@cloudmailin.net>",
      "subject"=>"asd",
      "x_cc_header"=>"",
      "message"=>"Received: from VMBX103.ihostexchange.net ([192.168.3.3]) by\r\n HUB103.ihostexchange.net ([66.46.182.53]) with mapi; Wed, 5 Oct 2011 17:12:44\r\n -0400\r\nFrom: SMS User <5555555555@tmomail.net>\r\nTo: Tracks <123123@cloudmailin.net>\r\nDate: Wed, 5 Oct 2011 17:12:43 -0400\r\nSubject: asd\r\nThread-Topic: asd\r\nThread-Index: AcyDo4aig2wghvcsTAOkleWqi4t/FQ==\r\nMessage-ID: <7D7CB176-7559-4997-A301-8DF9726264C7@tmomail.net>\r\nAccept-Language: de-DE, en-US\r\nContent-Language: en-US\r\nX-MS-Has-Attach:\r\nX-MS-TNEF-Correlator:\r\nacceptlanguage: de-DE, en-US\r\nContent-Type: text/plain; charset=\"us-ascii\"\r\nContent-Transfer-Encoding: quoted-printable\r\nMIME-Version: 1.0\r\n\r\nasdasd\r\n"
    }
    
    assert_response 403
  end
  
  def test_cloudmailin_integration_unknown_address
    SITE_CONFIG['cloudmailin'] = "123456789"
    post :cloudmailin, {
      "html"=>"",
      "plain"=>"asdasd",
      "x_to_header"=>"[\"81496ecea21032d35a7a@cloudmailin.net\"]",
      "disposable"=>"",
      "from"=>"444444444444@tmomail.net",
      "signature"=>"6d2df0e807bfa9b77d24c31dce6d4515",
      "to"=>"<123123@cloudmailin.net>",
      "subject"=>"asd",
      "x_cc_header"=>"",
      "message"=>"Received: from VMBX103.ihostexchange.net ([192.168.3.3]) by\r\n HUB103.ihostexchange.net ([66.46.182.53]) with mapi; Wed, 5 Oct 2011 17:12:44\r\n -0400\r\nFrom: SMS User <444444444444@tmomail.net>\r\nTo: Tracks <123123@cloudmailin.net>\r\nDate: Wed, 5 Oct 2011 17:12:43 -0400\r\nSubject: asd\r\nThread-Topic: asd\r\nThread-Index: AcyDo4aig2wghvcsTAOkleWqi4t/FQ==\r\nMessage-ID: <7D7CB176-7559-4997-A301-8DF9726264C7@tmomail.net>\r\nAccept-Language: de-DE, en-US\r\nContent-Language: en-US\r\nX-MS-Has-Attach:\r\nX-MS-TNEF-Correlator:\r\nacceptlanguage: de-DE, en-US\r\nContent-Type: text/plain; charset=\"us-ascii\"\r\nContent-Transfer-Encoding: quoted-printable\r\nMIME-Version: 1.0\r\n\r\nasdasd\r\n"
    }
    
    assert_response 404
  end
  
end
