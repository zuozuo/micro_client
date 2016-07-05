require 'test_helper'

module MicroClient
  class Test < ActiveSupport::TestCase
    test 'MicroClient Modules' do
      assert_kind_of Module, MicroClient
    end
  end
end
