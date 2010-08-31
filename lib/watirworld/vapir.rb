watirworld_lib = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift(watirworld_lib) unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == File.expand_path(watirworld_lib) }
require 'watirworld'

require 'vapir'

require 'vapir-firefox/clear_tracks.rb'

Vapir::Browser.default= 'firefox'

module WatirWorld
  module VapirWorld
    def self.browser(options={})
      options = {:launch => true}.merge(options)
      if @browser && @browser.exists?
        @browser
      elsif options[:launch]
        @browser=Vapir::Browser.new(:profile => 'jssh', :timeout => 60)
      else
        nil
      end
    end
    def browser(options={})
      WatirWorld::VapirWorld.browser(options)
    end
    
    def assert_successful_response
      status = browser.response_status_code
      if status != 200
=begin
        filename = "vapir-#{Time.now.to_i}.html"
        File.open(RAILS_ROOT + "/tmp/#{filename}", "w") do |f|
          f.write browser.outer_html
        end
        `open tmp/#{filename}`
=end
        raise "Browser returned Response Code #{status}"
      end
    end
  end
end

World(WatirWorld::VapirWorld)

require File.join(WatirWorld::StepsDir, 'common_steps.rb')

at_exit do
  browser = WatirWorld::VapirWorld.browser(:launch => false)
  if browser && browser.exists?
    browser.close
  end
end
