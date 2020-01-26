# Yet Another Command Line Argument Parser?

Short answer, _Yes_, long answer, _Yes_ because I need one
that does what I want.

## What Do I want?

**N.B.** All following speculations are sourrounded by this setup code

```ruby around
    describe "Ruby like Syntax" do
      let(:parser) {Lab42::Rgxargs.new}
      ...
    end
```

* Ruby like syntax of course

So, event without any configuration I can slurp in a command line like the following
`alpha: 42 :hello world` 

```ruby speculate
      it "is just parsed into options and positionals" do
        expect(parser.parse(%w[alpha: 42 world :hello])).to eq([
          OpenStruct.new(alpha: "42", hello: true), # These are the keywords
          %w[world], # These are the positionals
          [] # And these would be the errors
        ])
      end
```

* Conversion of keyword parameters

```ruby speculate
   context "integer conversion" do
      before do
        parser.add_conversion(:lower, %r{\A([-+]?\d+)}, &:to_i)
      end
      it "converts the argument" do
        expect(parser.parse(%w[lower: 42])).to eq([
          OpenStruct.new(lower: 42), [], []
        ])
      end
    end
```

Such common converters are predefined of course

```ruby speculate
    describe "custom made convertes for keyword parameters" do
      before do
        parser.add_conversion(:lower, :int)
      end
      it "converts the argument" do
        expect(parser.parse(%w[lower: 42])).to eq([
          OpenStruct.new(lower: 42), [], []
        ])
      end
    end
    
```

Both converters do return errors if non integers are passed in

```ruby speculate
    
```

\

\

\
