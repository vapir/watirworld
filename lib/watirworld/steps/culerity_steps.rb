# these are steps that only work in culerity 

When /^I wait for the AJAX call to finish$/ do
  browser.wait_while do
    begin
      count = browser.execute_script("window.running_ajax_calls").to_i
      count.to_i > 0
    rescue => e
      if e.message.include?('HtmlunitCorejsJavascript::Undefined')
        raise "For 'I wait for the AJAX call to finish' to work please include culerity.js after including jQuery. If you don't use jQuery please rewrite culerity.js accordingly."
      else
        raise(e)
      end
    end
  end
end

