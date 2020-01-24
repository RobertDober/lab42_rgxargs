RSpec.describe Lab42::Rgxargs do
  let(:parser) { described_class.new }

  context "we have some syntax being assigned to :range, let us see how we can escape matching values into args" do
    before do
      parser.define_arg(:range) do
        syntax(%r{(\d+)}){ |n| Range.new(n.to_i, n.to_i) }
        syntax(:zero, 0..0)
      end
    end
    it "if we do nothing, matching values go into options[:range]" do
      expect(parser.parse(%w[zero])).to eq(correct(range: 0..0))
    end
    it "if we want to escape all values -- does just fine" do
      expect(parser.parse(%w[-- zero zero])).to eq(correct(%w[zero zero]))
    end
    it "however we can also escape only the first zero" do
      expect(parser.parse(%w[\zero alpha zero])).to eq(correct(%w[zero alpha], range: 0..0))
    end

    it "this works for the numbers too, of course" do
      expect(parser.parse(%w[\42 42])).to eq(correct(%w[42], range: 42..42))
    end
  end
  
end
