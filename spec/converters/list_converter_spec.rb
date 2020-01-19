RSpec.describe Lab42::Rgxargs do
  let(:parser) { described_class.new }

  context "list converters for params" do
    before do
      parser.add_conversion(:a, :list)
    end

    it "works for many elements" do
      expect( parser.parse(%w{a: 1,2}) ).to eq(correct(a: %w{1 2}))
    end

    it "works for one element" do
      expect( parser.parse(%w{a: 12}) ).to eq(correct(a: %w{12}))
    end
  end

  context "custom list converter for params" do
    before do
      parser.add_conversion(:a, parser.list_matcher(%w{v p x})) 
    end

    it "works for a combination of v, p and x" do
      expect( parser.parse(%w{a: v,x,v}) ).to eq(correct(a: %w{v x v}))
    end

    it "but gives errors otherwise" do
      expect( parser.parse(%w{a: v,r,v}) ).to \
      eq([OpenStruct.new(a: nil), [], 
          [[:syntax_error, :a, "v,r,v does not match (?-mix:\\A((?:v|p|x)(?:,(?:v|p|x))*)\\z)"]]])
    end
  end

  context "integer lists" do
    before do
      parser.add_conversion(:a, :int_list)
    end
    it "just work" do
      expect( parser.parse(%w{a: 1,2,-4}) ).to eq(correct(a: [1, 2, -4]))
    end
  end

  context "integer ranges" do
    before do
      parser.add_conversion(:a, :int_range)
    end
    it "works too" do
      expect( parser.parse(%w{a: 1..4}) ).to eq(correct(a: 1..4))
    end
    it "supports an alternative syntax" do
      expect( parser.parse(%w{a: 1-4}) ).to eq(correct(a: 1..4))
    end

  end

end
