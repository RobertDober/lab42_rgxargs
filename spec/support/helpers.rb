module Support
  module Helpers

    def correct(positionals=[], **options)
      [OpenStruct.new(**options), positionals, []]
    end

    def empty_correct positionals
      [OpenStruct.new, positionals, []]
    end
  end
end

RSpec.configure do |conf|
  conf.include Support::Helpers
end
