def fixture(filename)
  File.expand_path("../fixtures/#{filename}", __FILE__)
end

module Loginator
  module Test
    module Fixtures
    end
  end
end
