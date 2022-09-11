module Support
  module Helpers
    def correct(positionals=[], **options)
      [L42::Map.new(**options), positionals, []]
    end

    def empty_correct positionals
      [L42::Map.new, positionals, []]
    end
  end
end

RSpec.configure do |conf|
  conf.include Support::Helpers
end
