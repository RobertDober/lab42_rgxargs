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
  end

  def correct(positionals=[], **options)
    [OpenStruct.new(**options), positionals, []]
  end

  def empty_correct positionals
    [OpenStruct.new, positionals, []]
  end
  
end
