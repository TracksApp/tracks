module SeleniumHelper
  include SeleniumOnRails::SuiteRenderer
  include SeleniumOnRails::FixtureLoader
  
  def test_case_name filename
    File.basename(filename).sub(/\..*/,'').humanize
  end
end
