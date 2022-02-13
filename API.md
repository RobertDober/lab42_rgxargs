
# The Easy Peasy Vanilla Case

This does not as yet bring much value, compared to `OptParser` well, still
it might be easier to use and give a quick result, sufficient for many projecs.

And of course, we get the Ruby Syntax (why using Posix if so many tools already parse posix options?)

That said, Posix support is on the Roadmap.

### Context: Ruby like default syntax

Given a parser and a helper
```ruby
    let(:parser) {Lab42::Rgxargs.new}

    private
    def os(**kwds)
      OpenStruct.new(kwds)
    end
```

Then it parses the args into kwds and positionals
```ruby
      kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b c: 1})
      expect(kwds).to eq(os(a: "42", b: true, c: "1"))
```

And thhe default parser, w/o any configuration can only check for one thing, that a keyword param is followed by a value

```ruby
    _, _, errors = parser.parse(%w{a: })
    expect(errors).to eq([[:missing_required_value, :a]])
```
