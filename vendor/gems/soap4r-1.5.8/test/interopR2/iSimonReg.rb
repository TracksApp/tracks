require 'soap/soap'
require 'soap/rpcUtils'

module SimonReg
  TypeNS = 'http://soap.pocketsoap.com/registration/types'

  module Services

    InterfaceNS = 'http://soap.pocketsoap.com/registration/services'

    class Service
      include SOAP::Marshallable
      @typeName = 'Service'
      @typeNamespace = SimonReg::TypeNS

      attr_accessor :id, :name, :description, :wsdlURL, :websiteURL

      def initialize( id = nil, name = nil, description = nil, wsdlURL = nil, websiteURL = nil )

	@id = id
	@name = name
	@description = description
	@wsdlURL = wsdlURL
	@websiteURL = websiteURL
      end
    end

    Methods = {
      'ServiceList' => [ 'services' ],
      'Servers' => [ 'Servers', 'serviceID' ],
      'Clients' => [ 'Clients', 'serviceID' ],
    }
  end

  module Clients

    InterfaceNS = 'http://soap.pocketsoap.com/registration/clients'

    class ClientInfo
      include SOAP::Marshallable
      @typeName = 'clientInfo'
      @typeNamespace = SimonReg::TypeNS

      attr_accessor :name, :version, :resultsURL

      def initialize( name = nil, version = nil, resultsURL = nil )

	@name = name
	@version = version
	@resultsURL = resultsURL
      end
    end

    Methods = {
      'RegisterClient' => [ 'clientID', 'serviceID', 'clientInfo' ],
      'UpdateClient' => [ 'void', 'clientID', 'clientInfo' ],
      'RemoveClient' => [ 'void', 'clientID' ],
    }
  end

  module Servers

    InterfaceNS = 'http://soap.pocketsoap.com/registration/servers'

    class ServerInfo
      include SOAP::Marshallable
      @typeName = 'serverInfo'
      @typeNamespace = SimonReg::TypeNS

      attr_accessor :name, :version, :endpointURL, :wsdlURL

      def initialize( name = nil, version = nil, endpointURL = nil, wsdlURL = nil )

	@name = name
	@version = version
	@endpointURL = endpointURL
	@wsdlURL = wsdlURL
      end
    end

    Methods = {
      'RegisterServer' => [ 'serverID', 'serviceID', 'serverInfo' ],
      'UpdateServer' => [ 'void', 'serverID', 'serverInfo' ],
      'RemoveServer' => [ 'void', 'serverID' ],
    }
  end

  module Subscriber

    InterfaceNS = 'http://soap.pocketsoap.com/registration/subscriber'

    class SubscriberInfo
      include SOAP::Marshallable
      @typeName = 'subscriberInfo'
      @typeNamespace = SimonReg::TypeNS

      attr_accessor :notificationID, :expires

      def initialize( notificationID = nil, expires = nil )

	@notificationID = notificationID
	@expires = expires
      end
    end

    Methods = {
      'Subscribe' => [ 'subscriberInfo', 'serviceID', 'ServerChanges', 'ClientChanges', 'NotificationURL' ],
      'Renew' => [ 'expires', 'notificationID' ],
      'Cancel' => [ 'void', 'notificationID' ],
    }
  end
end
