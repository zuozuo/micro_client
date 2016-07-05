# Configure Rails Environment
require 'simplecov'
require 'pry'
require 'active_support/all'

SimpleCov.start do
  add_filter '/dummy/'
end

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.at_exit do
  result = {}
  [:covered_percent, :covered_percentages, :least_covered_file,
   :covered_strength, :covered_lines, :missed_lines].each do |name|
    # result[name] = SimpleCov.result.public_send(name)
  end

  File.open('coverage/result.json', 'w') do |f|
    f.write(result.to_json)
  end

  SimpleCov.result.format!
end

require 'minitest/reporters'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'
require 'mocha/mini_test'

ActiveSupport::TestCase.test_order = :sorted
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module ActiveSupport
  class TestCase
    def assert_call(obj, method, *args, &blk)
      return_value =
        if args.last && args.last.is_a?(Hash) && args.last.key?(:return_value)
          args.pop[:return_value]
        end

      mock = MiniTest::Mock.new
      mock.expect(:call, return_value, args)

      obj.stub(method, mock, &blk)
      mock.verify
    end
  end
end
