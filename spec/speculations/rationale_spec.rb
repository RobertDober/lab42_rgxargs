RSpec.describe "spec/speculations/RATIONALE.md" do
    describe "Ruby like Syntax" do
      let(:parser) {Lab42::Rgxargs.new}
      it "is just parsed into options and positionals" do
        expect(parser.parse(%w[alpha: 42 world :hello])).to eq([
          OpenStruct.new(alpha: "42", hello: true), # These are the keywords
          %w[world], # These are the positionals
          [] # And these would be the errors
        ])
      end
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
    
    
    end
end
