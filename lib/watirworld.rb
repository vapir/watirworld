watirworld_lib = File.dirname(__FILE__)
$LOAD_PATH.unshift(watirworld_lib) unless $LOAD_PATH.any?{|lp| File.expand_path(lp) == File.expand_path(watirworld_lib) }

has_world = self.methods.any?{|meth| meth.to_s=='World'}
unless has_world
  raise RuntimeError, "Cucumber must be loaded and its DSL must define the World method before WatirWorld can be used!"
end

module WatirWorld
  StepsDir = File.join(File.dirname(__FILE__), 'watirworld', 'steps')
  
  # helper methods to extend the World, which rely on the Watir API. 
  module WatirAPIHelper
    # returns an element found by id, name, or label text. takes an element type, which is a symbol 
    # (such as :text_field or :div) and a value of the desired element, which should be either the 
    # element's id, name, or the text of a label pointing at the element. 
    def find_by_label_or_id(element_type, value)
      [:id, :name].each do |how|
        if (element = browser.send(element_type, how, value)).exists?
          return element
        end
      end
      # try to find a label: match label text ignoring whitespace at beginning and end, and ignoring '*' and ':' at the end. 
      pre=/^\s*/.source
      post=/[\s\*:]*$/.source
      if (label = browser.label(:text, Regexp.new(pre+Regexp.escape(value)+post, Regexp::MULTILINE))).exists?
        if label.respond_to?(:for_element)
          return label.for_element # todo: check that the for_element actually matches the given element type 
        else
          element = browser.send(element_type, :id, label.for)
          element.assert_exists
          return element
        end
      end
      raise("#{element_type} not found using  \"#{value}\"")
    end
  end
end
World(WatirWorld::WatirAPIHelper)

class RailsLauncher
  def initialize(port, environment='test')
    @port = port
    @rails_server_pid = rails_server_pid = fork do
      $stdin.reopen "/dev/null"
      $stdout.reopen "/dev/null"
      $stderr.reopen "/dev/null"
      Dir.chdir(Rails.root) do
        if Rails::VERSION::MAJOR < 3
          exec "script/server -e #{environment} -p #{port}"
        else
          exec "rails server -e #{environment} -p #{port}"
        end
      end
    end
      
    # wait for the server to become responsive 
    running = false
    Timeout.timeout(30) do
      while !running
        begin
          sock=TCPSocket.new('localhost', port)
          running = true
          sock.close
        rescue
          sleep 0.2
        end
      end
    end
    at_exit do
      Process.kill(6, rails_server_pid)
    end
  end
end
