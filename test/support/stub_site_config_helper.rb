require 'minitest/stub_const'

module StubSiteConfigHelper
  def stub_site_config
    Object.stub_const(:SITE_CONFIG, SITE_CONFIG.clone) do
      yield
    end
  end
end
