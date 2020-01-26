class Lab42::Rgxargs::Syntax

  attr_reader :converter, :matcher

  def matches? value
    if match = matcher.match(value)
      yield converter.(*match.captures)
      true
    end
  end

  private
  
  def initialize matcher, converter
    @converter = converter
    @matcher   = matcher
  end

end
