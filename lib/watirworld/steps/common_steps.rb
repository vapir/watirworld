Given /^(?:|I )am on (.+)$/ do |page_name|
  path = path_to(page_name)
  browser.goto @host + path
end

When /I follow "([^\"]*)"/ do |link|
  _link = [
    [:text, /^#{Regexp.escape(link)}$/ ],
    [:id, link],
    [:title, link],
    [:text, /#{Regexp.escape(link)}/ ],
  ].map{|args| browser.link(*args)}.find{|__link| __link.exist?}
  raise "link \"#{link}\" not found" unless _link
  _link.click
  assert_successful_response
end

When /I press "([^\"]*)"/ do |button|
  browser.button(:caption, button).click
  assert_successful_response
end

When /I fill in "([^\"]*)" with "([^\"]*)"/ do |field, value|
  find_by_label_or_id(:text_field, field).set(value)
end

When /I fill in "([^\"]*)" for "([^\"]*)"/ do |value, field|
  find_by_label_or_id(:text_field, field).set(value)
end

When /I check "([^\"]*)"/ do |field|
  find_by_label_or_id(:check_box, field).set(true)
end

When /^I uncheck "([^\"]*)"$/ do |field|
  find_by_label_or_id(:check_box, field).set(false)
end

When /I select "([^\"]*)" from "([^\"]*)"/ do |value, field|
  find_by_label_or_id(:select_list, field).select value
end

When /I choose "([^\"]*)"/ do |field|
  find_by_label_or_id(:radio, field).set(true)
end

When /I visit (.+)/ do |path|
  When "I go to #{path}"
end

When /I go to (.+)/ do |path|
  browser.goto @host + path_to(path)
  assert_successful_response
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(browser.url)
  expected_path = URI.parse(path_to(page_name))

  # If our expected path doesn't specify a query-string, ignore any query string
  # in the current path
  current_path, expected_path = if expected_path.query.nil?
    [ current_path.path, expected_path.path ]
  else
    [ current_path.select(:path, :query).compact.join('?'), path_to(page_name) ]
  end

  if defined?(Spec::Rails::Matchers)
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^the "([^\"]*)" field should contain "([^\"]*)"$/ do |field, value|
  f = find_by_label_or_id(:text_field, field)
  if defined?(Spec::Rails::Matchers)
    f.text.should =~ /#{Regexp::escape(value)}/
  else
    assert_match(/#{Regexp::escape(value)}/, f.text)
  end
end

Then /^the "([^\"]*)" field should not contain "([^\"]*)"$/ do |field, value|
  f = find_by_label_or_id(:text_field, field)
  if defined?(Spec::Rails::Matchers)
    f.text.should_not =~ /#{Regexp::escape(value)}/
  else
    assert_no_match(/#{Regexp::escape(value)}/, f.text)
  end
end

Then /^the "([^\"]*)" checkbox should be checked$/ do |label|
  f = find_by_label_or_id(:check_box, label)
  if defined?(Spec::Rails::Matchers)
    f.should be_checked
  else
    assert f.checked?
  end
end

Then /^the "([^\"]*)" checkbox should not be checked$/ do |label|
  f = find_by_label_or_id(:check_box, label)
  if defined?(Spec::Rails::Matchers)
   f.should_not be_checked
  else
    assert !f.checked?
  end
end

Then /I should see "([^\"]*)"/ do |text|
  assert(browser.text.include?(text), "Browser text should include #{text.inspect}; it does not")
end

Then /I should not see "([^\"]*)"/ do |text|
  div = browser.div(:text, /#{Regexp::escape(text)}/)
  div.should_not be_exist
end
