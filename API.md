
# The Easy Peasy Vanilla Case

This does not as yet bring much value, compared to `OptParser` well, still
it might be easier to use and give a quick result, sufficient for many projecs.

And of course, we get the Ruby Syntax (why using Posix if so many tools already parse posix options?)

That said, Posix support is on the Roadmap.

But let us begin by simply parse whatever comes our way:

```ruby around
    describe "Ruby like Syntax and default behavior" do
      let(:parser) {Lab42::Rgxargs.new}
      ...

      private
      def os(**kwds)
        OpenStruct.new(kwds)
      end
    end
```
```

```ruby speculate
    it "parses the args into kwds and positionals" do
      kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b c: 1})
      expect(kwds).to eq(os(a: "42", b: true, c: "1"))
    end
```

The default parser, w/o any configuration can only check for one thing, that a keyword param is followed by a value

```ruby speculate
    _, _, errors = parser.parse(%w{a: })
    expect(errors).to eq([])


    
```
