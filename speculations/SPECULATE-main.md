# Hi this is **SPECULATE** your new best friend, who _speculates_ what your code will do

Actually not, it creates specs out of (this) documentation :)


```ruby speculate
describe "how it works" do
  let(:parser) { Lab42::Rgxargs.new }


  it "works for empty" do
    expect(parser.parse([])).to eq(empty_correct([]))
  end
end
```
