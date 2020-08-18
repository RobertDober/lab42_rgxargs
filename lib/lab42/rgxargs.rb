require 'forwardable'
require 'ostruct'
require 'lab42/enumerable'
module Lab42

  class Rgxargs
    require_relative 'rgxargs/checker'
    require_relative 'rgxargs/constrainer'
    require_relative 'rgxargs/predefined_matchers'
    require_relative 'rgxargs/argument_matcher'
    require_relative 'rgxargs/syntax_definer'
    include Checker
    include Constrainer

    Predefined = PredefinedMatchers

    extend Forwardable
    def_delegators Predefined, :list_matcher

    attr_reader :allowed, :args, :conversions, :defaults, :defined_rules, :errors, :options, :required, :syntaxes


    def add_conversion(param, conversion=nil, required=nil, &block)
      case conversion
      when Symbol
        _add_symbolic_conversion(param, conversion, required)
      when NilClass
        _add_simple_conversion(param, block)
      else
        _add_proc_conversion(param, conversion, block, required)
      end
    end

    def add_syntax(rgx, parser=nil, as: nil)
      case rgx
      when Symbol, Regexp
        syntaxes << ArgumentMatcher.new(rgx, parser, arg_name: as)
      when Array
        rgx.each do |rg1|
          add_syntax( rg1, parser, as: as)
        end
      end
    end

    def define_arg name, &blk
      SyntaxDefiner.new(self, name).run(blk)
    end

    def parse argv
      until argv.empty?
        argv = _parse_next argv
      end
      _check_required_kwds
      [options, args, errors]
    end


    def allows name, matcher=nil, &converter
      add_conversion(name, matcher, &converter)
    end

    def needs name, matcher=nil, &converter
      add_conversion(name, matcher, :required, &converter)
    end

    private

    def initialize &blk
      @args          = []
      @allowed       = nil
      @conversions   = {}
      @defaults      = {}
      @defined_rules = []
      @errors        = []
      @required      = ::Set.new
      @syntaxes      = []

      instance_exec(&blk) if blk
      @options       = ::OpenStruct.new(defaults)
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
          conv[1].(*match.captures)
        else
          errors << [:syntax_error, name, "#{value} does not match #{conv.first}"]
          nil
        end
      else
        value
      end
    end

    def _add_proc_conversion(param, conversion, block, required)
      Array(param).each do |para|
        @required.add para if required == :required
        conversions[para] =  block ? [conversion, block] : conversion
      end
    end

    def _add_simple_conversion(param, block)
      Array(param).each do |para|
        conversions[para] = block
      end
    end

    def _add_symbolic_conversion(param, conversion, required)
      Array(param).each do |para|
        @required.add para if required == :required
        conversions[para] = Predefined.fetch(conversion, conversion)
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
        switch = $1.gsub('-','_').to_sym
        _check_switch(switch)
        options[switch]=true
        rest
      when %r{(.*):\z}
        kwd = $1.gsub('-', '_').to_sym
        _check_kwd(kwd)
        _parse_value kwd, rest
      when %r{\A\\(.*)}
        args << $1
        rest
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
