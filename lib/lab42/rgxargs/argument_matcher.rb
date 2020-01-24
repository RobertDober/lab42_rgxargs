class Lab42::Rgxargs::ArgumentMatcher
  require_relative './error'
  require_relative './predefined_matchers'

  Predefined = Lab42::Rgxargs::PredefinedMatchers 
  Error      = Lab42::Rgxargs::Error

  attr_reader :arg_name, :converter, :matcher



  def match value
    case matcher
    when Regexp
      match = matcher.match(value)
      match && [converter.(match.captures), arg_name] 
    else
      matcher.to_s == value && [converter.(), arg_name]
    end
  end

  private

  def initialize(matcher, converter, arg_name: nil)
    @arg_name  = arg_name
    @matcher   = matcher
    @converter = converter || _get_predefined
  end

  def _get_predefined
    @matcher, converter = Predefined.fetch(matcher) { raise Error, "undefined syntax #{matcher}" }
    converter
  end

end
