require 'drb/drb'
require 'rw-lib'
require 'interopResultBase'

class RWikiInteropService
  def initialize
    @rwiki_uri = 'druby://localhost:7174'
    @rwiki = DRbObject.new(nil, @rwiki_uri)
  end

  #  [ 'addResults', ['in', 'interopResults' ]]
  #  [ 'deleteResults', ['in', 'client'], ['in', 'server']]

  def addResults(interopResults)
    pageName = pageName(interopResults.client, interopResults.server)

    passResults = interopResults.find_all { | testResult |
      testResult.result
    }
    passStr = passResults.collect { | passResult |
      str = "* #{ passResult.testName } ((<[wiredump]|\"##{passResult.testName}\">))\n"
      if passResult.comment
	str << "\n  #{ passResult.comment.gsub(/[\r\n]/, '') }\n"
      end
      str
    }
    passStr = 'Nothing...' if passStr.empty?

    failResults = interopResults.find_all { | testResult |
      !testResult.result
    }
    failStr = failResults.collect { | failResult |
      str = ":#{ failResult.testName } ((<[wiredump]|\"##{failResult.testName}\">))\n  Result:\n"
      resultStr = failResult.comment.gsub(/\r?\n/, "\n    ")
      str << "    #{ resultStr }\n"
      str
    }
    failStr = 'Nothing!' if failStr.empty?

    pageStr =<<__EOS__
= #{ pageName }

* Date: #{ interopResults.dateTime }
* Server
  * Name: #{ interopResults.server.name }
  * Endpoint: #{ interopResults.server.uri }
  * WSDL: #{ interopResults.server.wsdl }
* Client
  * Name: #{ interopResults.client.name }
  * Endpoint: #{ interopResults.client.uri }
  * WSDL: #{ interopResults.client.wsdl }

== Pass

#{ passResults.size } / #{ interopResults.size }

#{ passStr }

== Fail

#{ failResults.size } / #{ interopResults.size }

#{ failStr }

== Wiredumps

__EOS__

    interopResults.each do | testResult |
      pageStr <<<<__EOS__
=== #{ testResult.testName }

  #{ testResult.wiredump.gsub(/\r/, '^M').gsub(/\t/, '^I').gsub(/\n/, "\n  ") }

__EOS__
    end

    set(pageName, pageStr)

    msg = "; #{ passResults.size } / #{ interopResults.size } (#{ interopResults.dateTime })"
    addLink(pageName, msg)
  end

  def deleteResults(client, server)
    set(pageName(client, server), '')
  end

private

  def set(pageName, pageSrc)
    page = @rwiki.page(pageName)
    page.src = pageSrc
  end

  def pageName(client, server)
    "InteropResults::#{ client.name }-#{ server.name }"
  end

  def addLink(pageName, msg)
    page = @rwiki.page('InteropResults')
    # Race condition...  Page source might be mixed with others's.
    page.src = (page.src || '') << "\n* ((<\"#{ pageName }\">))\n  #{ msg }"
  end
end
