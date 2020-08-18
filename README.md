# lab42_rgxargs

parse args according to regexen

[![Build Status](https://travis-ci.org/RobertDober/lab42_rgxargs.svg?branch=master)](https://travis-ci.org/RobertDober/lab42_rgxargs)
[![Gem Version](https://badge.fury.io/rb/lab42_rgxargs.svg)](http://badge.fury.io/rb/lab42_rgxargs)
<!--
     [![Code Climate](https://codeclimate.com/github/RobertDober/lab42_streams/badges/gpa.svg)](https://codeclimate.com/github/RobertDober/lab42_streams)
  [![Issue Count](https://codeclimate.com/github/RobertDober/lab42_streams/badges/issue_count.svg)](https://codeclimate.com/github/RobertDober/lab42_streams)
  [![Test Coverage](https://codeclimate.com/github/RobertDober/lab42_streams/badges/coverage.svg)](https://codeclimate.com/github/RobertDober/lab42_streams)
-->


## Yet Another Command Line Argument Parser?

Short answer, _Yes_, long answer, _Yes_ because I need one
that does what I want.

### What Do I want?

Simple usage with minimum boilerplate

```ruby :include
      let(:parser) {Lab42::Rgxargs.new}
      def os(**kwds); OpenStruct.new(kwds) end
```

#### Context No Config Out Of The Box

That gives me a ruby like syntax for keywords and here we go:

```ruby :example Plain Vanilla Parsing
      kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b})
      expect(kwds).to eq(os(a: "42", b: true))
      expect(positionals).to eq(%w{hello})
```

The only error one can get with this null configuration is a missing value for trailing keyword arg

```ruby :example
      kwds, _, errors = parser.parse(%w{a: b: a:})
      expect(kwds).to eq(os(a: "b:"))
      expect(errors).to eq([[:missing_required_value, :a]])
```


but what if I want

### Some Features

like

#### Context Conversion Of Keyword Parameters

By adding this configuration to the parser

```ruby :before
      parser.add_conversion(:lower, %r{\A([-+]?\d+)}, &:to_i)
  
```

Now the parsed value for the `lower` argument will be an `Integer`, while
the other parsed values remain `Strings` 

```ruby :example Explicit Keyword Conversion
    expect(parser.parse(%w[lower: 42 upper: 43]).first)
      .to eq(os(lower: 42, upper: "43"))
```

Such common converters are predefined of course

```ruby :example Predefined Converter
      parser.add_conversion(:alpha, :int)
      expect(parser.parse(%w[alpha: 42]).first)
        .to eq(os(alpha: 42))
    
```


Both converters do return errors if non integers are passed in

```ruby :example Illegal Integer
    _, _, errors = parser.parse(%w{lower: hello})
    expect(errors).to eq([[:syntax_error, :lower, "hello does not match (?-mix:\\A([-+]?\\d+))"]])
    
```

#### Context General Syntax

Sometimes we want to define syntax for positional parameters too.

This can be done with the `add_syntax` method.

```ruby :example A custom syntax for defining a range
      parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(*captures){ Range.new(*captures.map(&:to_i)) })
      _, my_range, _ = parser.parse(%w{1..3})
      expect(my_range.first).to eq(1..3)
```

and is of course predefined

```ruby :example The predefined :range syntax
      parser.add_syntax(:range)
      _, my_range, _ = parser.parse(%w{1..3})
      expect(my_range.first).to eq(1..3)
    
```

Now the added syntaxen are of course applied to **all** arguments, e.g.

```ruby :example Lists and Ranges
      parser.add_syntax(:range)
      parser.add_syntax(:list)
      _, pos , _ = parser.parse(%w{ 1,2 1..3 42})
      list, range, answer = pos
      expect(list).to eq(%w{1 2}) # N.B. Strings
      expect(range).to eq(1..3)
      expect(answer).to eq(%w{42})  # N.B. Strings
    
```


There is a special `int_list` converter available

```ruby :example Intlists
      parser.add_syntax(:int_list)
      _, list, _ = parser.parse(%w{1,2,4})
      expect(list.first).to eq([1,2,4])
```

Of course a `add_syntax` (for positionals) and  `add_conversion` (for keywords) can be mixed using the same
converters under the hood

```ruby :example Mixing add_syntax and add_conversion
      parser.add_conversion([:lower, :upper], :int)
      parser.add_syntax([:int, :range])

      kwds, pos, _ = parser.parse(%w[42 lower: 1 upper: 2 1..3])
      expect(kwds).to eq(os(lower: 1, upper: 2))
      expect(pos).to eq([42, 1..3])
```


#### Context Giving Names to Syntaxes

Often times you might want to distinguish arguments by their syntax and not by their position.

Imagine a tool that compares a file's access time with a timestamp, then it might make sense to name
the positionals as follows:


```ruby :example Named Positionals

      parser.add_syntax(%r{\A(\d+:\d+:\d+)\z}, ->(ts){ ts }, as: :timestamp)
      kwds, positionals, _ = parser.parse(%w[foo 20:10:10])
      expect(kwds.timestamp).to eq("20:10:10")
      expect(positionals).to eq(%w{foo})
    
```

For more complex possibilities of timestamps one can use a little DSL

```ruby :example DSL for naming positionals

      parser.define_arg(:timestamp) do
        syntax(%r{\A(\d+:\d+)\z}, &:itself)
        syntax(%r{\A(\d{6,})\z}) { |capture| capture.to_i }
      end

      kwds, _, _ = parser.parse(%w[123456])
      expect(kwds.timestamp).to eq(123456)
    
```

#### Context Constraints

##### Allowing Keyword Params

Allowing keywords means, all others are forbidden

```ruby :example Allowing a keyword

    parser.allow_kwds(:version)

    _, _, errors = parser.parse(%w[vision: 41])
    expect(errors) == [[:unauthorized_kwd, :vision]]
    
```

and the allowed work as expected

```ruby :example Allowing a keyword, correct case

    parser.allow_kwds(:version)

    kwds, _, errors = parser.parse(%w[version: 42])
    expect(errors).to be_empty
    expect(kwds.version).to eq("42")
    
```

#### Require Keyword Params


```ruby :example Required Kwd Params are missing

    parser.require_kwds(:from)
    parser.add_conversion(:to, :int, :required)

    _, _, errors = parser.parse(%w[version: 42])
    expect(errors).to eq([
     [:required_kwd_missing, :from],
     [:required_kwd_missing, :to]
    ])
    
```

```ruby :example Required Kwd Params are present

    parser.require_kwds(:from)
    parser.add_conversion(:to, :int, :required)

    kwds, _, errors = parser.parse(%w[to: 2 from: 1])
    expect(errors).to be_empty
    expect(kwds).to eq(os(from: "1", to: 2))
    
```






## LICENSE

Copyright 2020 Robert Dober robert.dober@gmail.com

Apache-2.0 [c.f LICENSE](LICENSE)  
