# DO NOT EDIT!!!
# This file was generated from "API.md" with the speculate_about gem, if you modify this file
# one of two bad things will happen
# - your documentation specs are not correct
# - your modifications will be overwritten by the speculate rake task
# YOU HAVE BEEN WARNED
RSpec.describe "API.md" do
  # API.md:11
  context "Ruby like default syntax" do
    # API.md:14
    let(:parser) {Lab42::Rgxargs.new}

    private
    def os(**kwds)
    L42::Map.new(**kwds)
    end
    it "it parses the args into kwds and positionals (API.md:24)" do
      kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b c: 1})
      expect(kwds).to eq(os(a: "42", b: true, c: "1"))
    end
    it "thhe default parser, w/o any configuration can only check for one thing, that a keyword param is followed by a value (API.md:31)" do
      _, _, errors = parser.parse(%w{a: })
      expect(errors).to eq([[:missing_required_value, :a]])
    end
  end
end
