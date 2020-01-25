RSpec.describe "SPECULATE.md" do
describe "how it works" do
  let(:parser) { Lab42::Rgxargs.new }


  it "works for empty" do
    expect(parser.parse([])).to eq(empty_correct([]))
  end
end
end
