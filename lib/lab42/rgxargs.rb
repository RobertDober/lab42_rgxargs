require 'forwardable'
require 'ostruct'
require 'lab42/enumerable'
module Lab42

  class Rgxargs
    require_relative 'rgxargs/predefined_matchers'
    require_relative 'rgxargs/argument_matcher'
    require_relative 'rgxargs/syntax_definer'
    Predefined = PredefinedMatchers

    extend Forwardable
    def_delegators Predefined, :list_matcher

    attr_reader :args, :conversions, :defined_rules, :errors, :options, :syntaxes


    def add_conversion(param, conversion)
      case conversion
      when Symbol
        conversions[param] = Predefined.fetch(conversion, conversion)
      else
        conversions[param] = conversion
      end
    end

    def add_syntax(rgx, parser=nil, as: nil)
      syntaxes << ArgumentMatcher.new(rgx, parser, arg_name: as) 
    end

    def define_arg name, &blk
      SyntaxDefiner.new(self, name).run(blk)
    end

    def parse argv
      until argv.empty?
        argv = _parse_next argv
      end
      [options, args, errors]
    end


    private

    def initialize &blk
      @args          = []
      @conversions   = {}
      @defined_rules = []
      @errors        = []
      @options       = OpenStruct.new
      @syntaxes      = []

      instance_exec(&blk) if blk
    end

    def _convert(value, name:) 
      conv = conversions.fetch(name, nil)
      case conv
      when Symbol
        value.send conv
      when Proc
        conv.(value)
      when Array
        if (match = conv.first.match(value))
          conv[1].(match.captures) 
        else
          errors << [:syntax_error, name, "#{value} does not match #{conv.first}"]
          nil
        end
      else
        value
      end
    end


    def _parse_next argv
      first, *rest = argv
      if first == '--'
        @args += rest
        return []
      end
      _parse_symbolic first, rest
    end

    def _parse_symbolic first, rest
      case first
      when %r{\A:(.*)}
        options[$1.gsub('-','_').to_sym]=true
        rest
      when %r{(.*):\z}
        _parse_value $1.gsub('-', '_').to_sym, rest
      else
        _parse_syntax(first)
        rest
      end
    end

    def _parse_syntax first
      value, as = syntaxes.find_value(first){ |matcher| matcher.match(first) }
      if as
        options[as] = value
      else
        args << value
      end
    end

    def _parse_value name, rest
      value, *rest1 = rest
      if value
        options[name] = _convert(value, name: name)
        return rest1
      end
      errors << [:missing_required_value, name]
      []
    end

  end
end
