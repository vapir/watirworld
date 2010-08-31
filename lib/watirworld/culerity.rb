watirworld_lib = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift(watirworld_lib) unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == File.expand_path(watirworld_lib) }
require 'watirworld'

require 'culerity'

module WatirWorld
  module CulerityWorld
    def self.server(options={})
      options = {:launch => true}.merge(options)
      if @server
        @server
      elsif options[:launch]
        @server = Culerity::run_server
      else
        nil
      end
    end
    def self.browser(options={})
      options = {:launch => true}.merge(options)
      if @browser && @browser.exists?
        @browser
      elsif options[:launch]
        @browser = Culerity::RemoteBrowserProxy.new(server, :browser => :firefox3,
          :javascript_exceptions => true,
          :resynchronize => true,
          :status_code_exceptions => true
        )
        @browser.log_level = :warning
        @browser
      else
        nil
      end
    end
    def server(options={})
      WatirWorld::CulerityWorld.server(options)
    end
    def browser(options={})
      WatirWorld::CulerityWorld.browser(options)
    end
  
    def assert_successful_response
      status = browser.page.web_response.status_code
      if(status == 302 || status == 301)
        location = browser.page.web_response.get_response_header_value('Location')
        puts "Being redirected to #{location}"
        browser.goto location
        assert_successful_response
      elsif status != 200
        filename = "culerity-#{Time.now.to_i}.html"
        File.open(RAILS_ROOT + "/tmp/#{filename}", "w") do |f|
          f.write browser.html
        end
        `open tmp/#{filename}`
        raise "Browser returned Response Code #{browser.page.web_response.status_code}"
      end
    end
  end
end

World(WatirWorld::CulerityWorld)

# should this move to watirworld.rb and be cross-browser? 
After do
  server.clear_proxies
  browser.clear_cookies
end

require File.join(WatirWorld::StepsDir, 'common_steps.rb')
require File.join(WatirWorld::StepsDir, 'culerity_steps.rb')

at_exit do
  browser = WatirWorld::CulerityWorld.browser(:launch => false)
  browser.close if browser && browser.exists?
  server = WatirWorld::CulerityWorld.server(:launch => false)
  server.exit_server if server
end
