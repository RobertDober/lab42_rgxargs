RSpec.describe Lab42::Rgxargs do
  let(:parser) { described_class.new }


  context "no custom definitions -> return options and args" do
    it "works for empty" do
      expect(parser.parse([])).to eq(empty_correct([]))
    end

    it "works for positionals only" do
      expect(parser.parse(%w{a b c})).to eq(empty_correct(%w{a b c}))
    end

    it "works for booleans only" do
      expect(parser.parse(%w{:a :b})).to eq(correct(a: true, b: true))
    end

    it "works for values only" do
      expect(parser.parse(%w{a: 42 b-c: 33})).to eq(correct(a: "42", b_c: "33"))
    end

    it "works for all of these" do
      expect(parser.parse(%w{a: 42 :he_llo? 123 b: 33 world})).to \
        eq(correct(%w{123 world}, a: "42", he_llo?: true, b: "33"))
    end

    it "missing values result in an error" do
      expect(parser.parse(%w{a: 1 b c:})).to eq([OpenStruct.new(a: "1"), ["b"], [[:missing_required_value, :c]]])
    end
  end

  context "custom converters" do
    it "can change strings to ints" do
      parser.add_conversion(:a, :to_i)
      expect(parser.parse(%w{a: 42 42})).to eq(correct(['42'], a: 42))
    end
    it "can define an aribitrary converter" do
      parser.add_conversion(:a, ->(v){ v.to_i * 2 })
      expect(parser.parse(%w{a: 21})).to eq(correct(a: 42))
    end
    it "can also use a predefined converter" do
      parser.add_conversion(:a, :list)
      expect(parser.parse(%w{a: 21,22})).to eq(correct(a: %w{21 22}))
    end
    it "issues an error if a predefined converter does not match" do
      parser.add_conversion(:a, :range)
      expect(parser.parse(%w{a: 21})).to eq([OpenStruct.new(a: nil), [], [[:syntax_error, :a, "21 does not match (?-mix:\\A(\\d+)\\.\\.(\\d+)\\z)"]]])
    end
    it "can use the matching syntax as well" do
      parser.add_conversion(:a, [%r{\A(.)\1\z}, ->((f,_)){f}])
      expect(parser.parse(%w{a: 22})).to eq(correct(a: "2"))
    end
    it "can use the matching syntax as well, and get the same errors" do
      parser.add_conversion(:a, [%r{\A(.)\1\z}, ->((f,_)){f}])
      expect(parser.parse(%w{a: 23})).to eq([OpenStruct.new(a: nil), [], [[:syntax_error, :a, "23 does not match (?-mix:\\A(.)\\1\\z)"]]])
    end
  end

  context "custom arguments" do
    it "can detect syntaxes in positional parameters" do
      parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(captures){ Range.new(*captures.map(&:to_i)) })
      expect( parser.parse(%w{1 2..4}) ).to eq(correct(['1', 2..4]))
    end
    it "has predefined converters for common syntaxes" do
      parser.add_syntax(:range)
      expect( parser.parse(%w{1 2..4}) ).to eq(correct(['1', 2..4]))
    end
    it "here is another one" do
      parser.add_syntax(:list)
      expect( parser.parse(%w{a,b c,d}) ).to eq(correct([%w{a b}, %w{c d}]))
    end
    it "can store depending on the syntax" do
      parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(captures){ Range.new(*captures.map(&:to_i)) }, as: :range)
      expect( parser.parse(%w{1 2..4}) ).to eq(correct(['1'], range: 2..4))
    end
  end

  
end
