RSpec.describe Lab42::Rgxargs do
  let(:parser) { described_class.new }

  shared_examples_for "multi syntax" do
    it "uses the explicit value for a range" do
      expect( parser.parse(%w{a 2..4}) ).to eq(correct(['a'], range: 2..4))
    end
    it "uses the explicit value for a single element range" do
      expect( parser.parse(%w{1}) ).to eq(correct([], range: 1..1))
    end
    it "uses a symbolic value for a range" do
      expect( parser.parse(%w{a zero}) ).to eq(correct(['a'], range: 0..0))
    end
    it "zero can still be used as a positional" do
      expect( parser.parse(%w{-- zero} )).to eq(correct(%w{zero}))
    end
  end

  context "can store depending on the syntax or an option" do
    before do
      parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(captures){ Range.new(*captures.map(&:to_i)) }, as: :range)
      parser.add_syntax(%r{(\d+)}, ->(captures){ Range.new(captures.first.to_i,captures.first.to_i) }, as: :range)
      parser.add_syntax(:zero, ->{ 0..0 }, as: :range)
    end
    it_behaves_like "multi syntax"
  end
  context "syntactic sugar to describe an arg with many syntaxes" do
    before do
      parser.define_arg(:range) do
        syntax(%r{(\d+)\.\.(\d+)}){ |captures| Range.new(*captures.map(&:to_i)) }
        syntax(%r{(\d+)}){ |captures| Range.new(captures.first.to_i,captures.first.to_i) }
        syntax(:zero, 0..0)
      end
    end
    it_behaves_like "multi syntax"
  end

end
