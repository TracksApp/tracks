xml.instruct!

xml.OpenSearchDescription 'xmlns' => "http://a9.com/-/spec/opensearch/1.1/" do

  xml.ShortName Tracks
  xml.Description t('integrations.opensearch_description')
  xml.InputEncoding 'UTF-8'
  xml.Image("data:image/x-icon;base64," + @icon_data,
			'width' => '16', 'height' => '16')
  xml.Url 'type' => 'text/html', 'method' => 'GET',
	'template' => url_for(:controller => 'search', :action => 'results',
						  :only_path => false) + '?search={searchTerms}'
end

