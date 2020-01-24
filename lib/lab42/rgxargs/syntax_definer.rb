class Lab42::Rgxargs::SyntaxDefiner

  attr_reader :arg_name, :parser

  def run code
    instance_exec(&code)
  end

  def syntax(matcher, value=nil, &blk)
    if value
      parser.add_syntax(matcher, ->(){value}, as: arg_name )
    else
      parser.add_syntax(matcher, blk, as: arg_name)
    end
  end

  private

  def initialize(parser, arg_name)
    @arg_name = arg_name
    @parser   = parser
  end
end
