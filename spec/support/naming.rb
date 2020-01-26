module Support
  module Naming
  INITIALS = [*'A'..'Z']

    def any_name length=10
      INITIALS.sample +
        SecureRandom.alphanumeric(length-1)
    end
  end
end
RSpec.configure do |conf|
  conf.include Support::Naming
end
