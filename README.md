# lab42_rgxargs

parse args according to regexen

[![Issue Count](https://codeclimate.com/github/RobertDober/lab42_rgxargs/badges/issue_count.svg)](https://codeclimate.com/github/RobertDober/lab42_rgxargs)
[![CI](https://github.com/robertdober/lab42_rgxargs/workflows/CI/badge.svg)](https://github.com/robertdober/lab42_rgxargs/actions)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/lab42_rgxargs/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/lab42_rgxargs?branch=master)
[![Gem Version](https://badge.fury.io/rb/lab42_rgxargs.svg)](http://badge.fury.io/rb/lab42_rgxargs)
[![Gem Downloads](https://img.shields.io/gem/dt/lab42_rgxargs.svg)](https://rubygems.org/gems/lab42_rgxargs)


## Yet Another Command Line Argument Parser?

Short answer, _Yes_, long answer, _Yes_ because I need one
that does what I want.

## How does it work?

Let us [speculate about](https://github.com/RobertDober/speculate_about) that:

## Context Setup for speculations

Given the default parser
```ruby
      let(:parser) {Lab42::Rgxargs.new}

      private
      def os(**kwds); L42::Map.new(**kwds) end
```
### What Do I want?

Simple usage with minimum boilerplate

#### Context No Config Out Of The Box

Then I can parse ruby syntax based arguments
```ruby
      kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b})
      expect(kwds).to eq(os(a: "42", b: true))
      expect(positionals).to eq(%w{hello})
```

And the only error one can get with this null configuration is a missing value for trailing keyword arg
```ruby
      kwds, _, errors = parser.parse(%w{a: b: a:})
      expect(kwds).to eq(os(a: "b:"))
      expect(errors).to eq([[:missing_required_value, :a]])
```

And for those who prefer to use pattern matching, like YHS
```ruby
      parser.parse(%w{a: b: a:}) => {a:}, [], errors
      expect(a).to eq("b:")
      expect(errors).to eq([[:missing_required_value, :a]])
```

#### Context Hash instead of L42::Map?

Although it can be very convenient to return an `OpenStruct` instance for the parsed options
a `Hash` instance might be a better choice, especially for pattern matching as `OpenStruct`
does not implement that protocol :(

Given a parser configured to return options as a Hash
```ruby
      let(:parser) { Lab42::Rgxargs.new(l42_map: false) }
      let(:posix) { Lab42::Rgxargs.new(l42_map: false, posix: true) }
```

Then we just get a good ol' Hash ;)
```ruby
    parser.parse(%w[a: 1 b: 2]) => {a: alpha, b: beta}, _, _
    expect(alpha.to_i + beta.to_i).to eq(3)

    posix.parse(%w[-n --a=1]) => {a: alpha, n: true}, _, _
    expect(alpha).to eq("1")
```


#### Context And What About Posix?

Given a posix enabled parser
```ruby
    let(:parser) { Lab42::Rgxargs.new(posix: true) }
```

Then I can parse posix style options
```ruby
      kwds, positionals, _errors = parser.parse(%w{-xy --a=42 --hello=b hello})
      expect(kwds).to eq(os(x:true, y:true, a: "42", hello: "b"))
      expect(positionals).to eq(%w{hello})
```

And we can use `--` to get positionals with leading `-`s and we also accept long flags (therefore the = is needed for values)
```ruby
      kwds, positionals, _errors = parser.parse(%w{-xy --a -- --hello=b})
      expect(kwds).to eq(os(x:true, y:true, a: true))
      expect(positionals).to eq(%w{--hello=b})
```

### Something A Little Bit More Elaborate?

like

#### Context: Conversion Of Keyword Parameters

Given this additional configuration, with a guard
```ruby
    before { parser.add_conversion(:lower, %r{\A([-+]?\d+)}, &:to_i) }
```

Then the parsed value for the `lower` argument will be an `Integer`, while the other parsed values remain `Strings`
```ruby
    expect(parser.parse(%w[lower: 42 upper: 43]).first)
      .to eq(os(lower: 42, upper: "43"))
```

##### Context: Withe predefined matchers

And such common converters are predefined of course, and thusly
```ruby
      parser.add_conversion(:alpha, :int)
      expect(parser.parse(%w[alpha: 42]).first)
        .to eq(os(alpha: 42))
```

And you can see all predefined matchers as follows
```ruby
    predefined_matchers =
      %w[ existing_dirs int int_list int_range list range ]
      .join("\n\t")
    expect(parser.predefined_matchers).to eq(predefined_matchers)
```

And We can also just pass in the converter without a guard
```ruby
    parser.add_conversion(:maybe_int, &:to_i)
      expect(parser.parse(%w[maybe_int: fourtytwo]).first)
        .to eq(os(maybe_int: 0))
```


But converters with guards do return meaningful error messages
```ruby
    _, _, errors = parser.parse(%w{lower: hello})
    expect(errors).to eq([[:syntax_error, :lower, "hello does not match (?-mix:\\A([-+]?\\d+))"]])
```

#### Context: General Syntax

Sometimes we want to define syntax for positional parameters too.

This can be done with the `add_syntax` method.

And therefore
```ruby
      parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(*captures){ Range.new(*captures.map(&:to_i)) })
      _, my_range, _ = parser.parse(%w{1..3})
      expect(my_range.first).to eq(1..3)
```

And we have some predefined syntaxes, of course
```ruby
      parser.add_syntax(:range)
      _, my_range, _ = parser.parse(%w{1..3})
      expect(my_range.first).to eq(1..3)
```

And they are of course applied to **all** arguments, e.g.
```ruby
      parser.add_syntax(:range)
      parser.add_syntax(:list)
      _, pos , _ = parser.parse(%w{ 1,2 1..3 42})
      list, range, answer = pos
      expect(list).to eq(%w{1 2}) # N.B. Strings
      expect(range).to eq(1..3)
      expect(answer).to eq(%w{42})  # N.B. Strings
```


And there is a special `int_list` converter available
```ruby
      parser.add_syntax(:int_list)
      _, list, _ = parser.parse(%w{1,2,4})
      expect(list.first).to eq([1,2,4])
```

And Of course a `add_syntax` (for positionals) and  `add_conversion` (for keywords) can be mixed using the same converters under the hood
```ruby
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


And therefore we have
```ruby

      parser.add_syntax(%r{\A(\d+:\d+:\d+)\z}, ->(ts){ ts }, as: :timestamp)
      kwds, positionals, _ = parser.parse(%w[foo 20:10:10])
      expect(kwds.timestamp).to eq("20:10:10")
      expect(positionals).to eq(%w{foo})
```

And for more complex possibilities of timestamps one can use a little DSL
```ruby

      parser.define_arg(:timestamp) do
        syntax(%r{\A(\d+:\d+)\z}, &:itself)
        syntax(%r{\A(\d{6,})\z}) { |capture| capture.to_i }
      end

      kwds, _, _ = parser.parse(%w[123456])
      expect(kwds.timestamp).to eq(123456)
```

#### Context Constraints

##### Context: Allowing Keyword Params

And Allowing keywords means, all others are forbidden
```ruby
    parser.allow_kwds(:version)

    _, _, errors = parser.parse(%w[vision: 41])
    expect(errors) == [[:unauthorized_kwd, :vision]]
```

But the allowed work as expected
```ruby
    parser.allow_kwds(:version)

    kwds, _, errors = parser.parse(%w[version: 42])
    expect(errors).to be_empty
    expect(kwds.version).to eq("42")
```

#### Context: Require Keyword Params

And if required keywords are absent...
```ruby
    parser.require_kwds(:from)
    parser.add_conversion(:to, :int, :required)

    _, _, errors = parser.parse(%w[version: 42])
    expect(errors).to eq([
     [:required_kwd_missing, :from],
     [:required_kwd_missing, :to]
    ])
```

But if they are present...
```ruby
    parser.require_kwds(:from)
    parser.add_conversion(:to, :int, :required)

    kwds, _, errors = parser.parse(%w[to: 2 from: 1])
    expect(errors).to be_empty
    expect(kwds).to eq(os(from: "1", to: 2))
```

#### Context Syntactic Sugar

Now all these API calls might not be your cup of tea, so let us add Syntactic Sugar to your Cup of Tea:

Given a simple definition for converting required parameters
```ruby
    let :parser do
      Lab42::Rgxargs.new do
        needs  :n, &:to_i
        allows :m, &:to_i
      end
    end
```

Then the conversion works of course as expected
```ruby
  kwds, _, _ = parser.parse(%w[n: alpha, m: 42])
  expect(kwds).to eq(os(n: 0, m: 42))
```

##### Context: Using predefined matches in the DSL

Given the directories `dir1` and `dir2` in the [fixtures directory](https://github.com/RobertDober/lab42_rgxargs/tree/master/spec/fixtures)
```ruby
    let :parser do
      Lab42::Rgxargs.new do
        allows :dirs, :existing_dirs
      end
    end
```

Then we can parse the keyword arguments with existing dirs w/o an error
```ruby
    glob = 'spec/fixtures/dir*'
    kwds, _, _ = parser.parse(["dirs:", glob])
    expect(kwds.dirs.sort).to eq(%w[spec/fixtures/dir1 spec/fixtures/dir2])
```

## LICENSE

Copyright 202[0,1,2] Robert Dober robert.dober@gmail.com,

Apache-2.0 [c.f LICENSE](LICENSE)  
