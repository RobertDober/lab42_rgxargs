# DO NOT EDIT!!!
# This file was generated from "README.md" with the speculate_about gem, if you modify this file
# one of two bad things will happen
# - your documentation specs are not correct
# - your modifications will be overwritten by the speculate rake task
# YOU HAVE BEEN WARNED
RSpec.describe "README.md" do
  # README.md:26
  context "Setup for speculations" do
    # README.md:29
    let(:parser) {Lab42::Rgxargs.new}

    private
    def os(**kwds); OpenStruct.new(kwds) end
    # README.md:39
    context "No Config Out Of The Box" do
      it "I can parse ruby syntax based arguments (README.md:42)" do
        kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b})
        expect(kwds).to eq(os(a: "42", b: true))
        expect(positionals).to eq(%w{hello})
      end
      it "the only error one can get with this null configuration is a missing value for trailing keyword arg (README.md:49)" do
        kwds, _, errors = parser.parse(%w{a: b: a:})
        expect(kwds).to eq(os(a: "b:"))
        expect(errors).to eq([[:missing_required_value, :a]])
      end
      it "for those who prefer to use pattern matching, like YHS (README.md:56)" do
        parser.parse(%w{a: b: a:}) => {a:}, [], errors
        expect(a).to eq("b:")
        expect(errors).to eq([[:missing_required_value, :a]])
      end
    end
    # README.md:62
    context "And What About Posix?" do
      # README.md:65
      let(:parser) { Lab42::Rgxargs.new(posix: true) }
      it "I can parse posix style options (README.md:70)" do
        kwds, positionals, _errors = parser.parse(%w{-xy --a=42 --hello=b hello})
        expect(kwds).to eq(os(x:true, y:true, a: "42", hello: "b"))
        expect(positionals).to eq(%w{hello})
      end
      it "we can use `--` to get positionals with leading `-`s and we also accept long flags (therefore the = is needed for values) (README.md:77)" do
        kwds, positionals, _errors = parser.parse(%w{-xy --a -- --hello=b})
        expect(kwds).to eq(os(x:true, y:true, a: true))
        expect(positionals).to eq(%w{--hello=b})
      end
    end
    # README.md:87
    context "Conversion Of Keyword Parameters" do
      # README.md:90
      before { parser.add_conversion(:lower, %r{\A([-+]?\d+)}, &:to_i) }
      it "the parsed value for the `lower` argument will be an `Integer`, while the other parsed values remain `Strings` (README.md:95)" do
        expect(parser.parse(%w[lower: 42 upper: 43]).first)
        .to eq(os(lower: 42, upper: "43"))
      end
      # README.md:100
      context "Withe predefined matchers" do
        it "such common converters are predefined of course, and thusly (README.md:103)" do
          parser.add_conversion(:alpha, :int)
          expect(parser.parse(%w[alpha: 42]).first)
          .to eq(os(alpha: 42))
        end
        it "you can see all predefined matchers as follows (README.md:110)" do
          predefined_matchers =
          %w[ existing_dirs int int_list int_range list range ]
          .join("\n\t")
          expect(parser.predefined_matchers).to eq(predefined_matchers)
        end
        it "We can also just pass in the converter without a guard (README.md:118)" do
          parser.add_conversion(:maybe_int, &:to_i)
          expect(parser.parse(%w[maybe_int: fourtytwo]).first)
          .to eq(os(maybe_int: 0))
        end
        it "converters with guards do return meaningful error messages (README.md:126)" do
          _, _, errors = parser.parse(%w{lower: hello})
          expect(errors).to eq([[:syntax_error, :lower, "hello does not match (?-mix:\\A([-+]?\\d+))"]])
        end
      end
    end
    # README.md:131
    context "General Syntax" do
      it "therefore (README.md:138)" do
        parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(*captures){ Range.new(*captures.map(&:to_i)) })
        _, my_range, _ = parser.parse(%w{1..3})
        expect(my_range.first).to eq(1..3)
      end
      it "we have some predefined syntaxes, of course (README.md:145)" do
        parser.add_syntax(:range)
        _, my_range, _ = parser.parse(%w{1..3})
        expect(my_range.first).to eq(1..3)
      end
      it "they are of course applied to **all** arguments, e.g. (README.md:152)" do
        parser.add_syntax(:range)
        parser.add_syntax(:list)
        _, pos , _ = parser.parse(%w{ 1,2 1..3 42})
        list, range, answer = pos
        expect(list).to eq(%w{1 2}) # N.B. Strings
        expect(range).to eq(1..3)
        expect(answer).to eq(%w{42})  # N.B. Strings
      end
      it "there is a special `int_list` converter available (README.md:164)" do
        parser.add_syntax(:int_list)
        _, list, _ = parser.parse(%w{1,2,4})
        expect(list.first).to eq([1,2,4])
      end
      it "Of course a `add_syntax` (for positionals) and  `add_conversion` (for keywords) can be mixed using the same converters under the hood (README.md:171)" do
        parser.add_conversion([:lower, :upper], :int)
        parser.add_syntax([:int, :range])

        kwds, pos, _ = parser.parse(%w[42 lower: 1 upper: 2 1..3])
        expect(kwds).to eq(os(lower: 1, upper: 2))
        expect(pos).to eq([42, 1..3])
      end
    end
    # README.md:181
    context "Giving Names to Syntaxes" do
      it "therefore we have (README.md:190)" do

        parser.add_syntax(%r{\A(\d+:\d+:\d+)\z}, ->(ts){ ts }, as: :timestamp)
        kwds, positionals, _ = parser.parse(%w[foo 20:10:10])
        expect(kwds.timestamp).to eq("20:10:10")
        expect(positionals).to eq(%w{foo})
      end
      it "for more complex possibilities of timestamps one can use a little DSL (README.md:199)" do

        parser.define_arg(:timestamp) do
        syntax(%r{\A(\d+:\d+)\z}, &:itself)
        syntax(%r{\A(\d{6,})\z}) { |capture| capture.to_i }
        end

        kwds, _, _ = parser.parse(%w[123456])
        expect(kwds.timestamp).to eq(123456)
      end
    end
    # README.md:210
    context "Constraints" do
      # README.md:212
      context "Allowing Keyword Params" do
        it "Allowing keywords means, all others are forbidden (README.md:215)" do
          parser.allow_kwds(:version)

          _, _, errors = parser.parse(%w[vision: 41])
          expect(errors) == [[:unauthorized_kwd, :vision]]
        end
        it "the allowed work as expected (README.md:223)" do
          parser.allow_kwds(:version)

          kwds, _, errors = parser.parse(%w[version: 42])
          expect(errors).to be_empty
          expect(kwds.version).to eq("42")
        end
      end
    end
    # README.md:231
    context "Require Keyword Params" do
      it "if required keywords are absent... (README.md:234)" do
        parser.require_kwds(:from)
        parser.add_conversion(:to, :int, :required)

        _, _, errors = parser.parse(%w[version: 42])
        expect(errors).to eq([
        [:required_kwd_missing, :from],
        [:required_kwd_missing, :to]
        ])
      end
      it "if they are present... (README.md:246)" do
        parser.require_kwds(:from)
        parser.add_conversion(:to, :int, :required)

        kwds, _, errors = parser.parse(%w[to: 2 from: 1])
        expect(errors).to be_empty
        expect(kwds).to eq(os(from: "1", to: 2))
      end
    end
    # README.md:255
    context "Syntactic Sugar" do
      # README.md:260
      let :parser do
      Lab42::Rgxargs.new do
      needs  :n, &:to_i
      allows :m, &:to_i
      end
      end
      it "the conversion works of course as expected (README.md:270)" do
        kwds, _, _ = parser.parse(%w[n: alpha, m: 42])
        expect(kwds).to eq(os(n: 0, m: 42))
      end
      # README.md:275
      context "Using predefined matches in the DSL" do
        # README.md:278
        let :parser do
        Lab42::Rgxargs.new do
        allows :dirs, :existing_dirs
        end
        end
        it "we can parse the keyword arguments with existing dirs w/o an error (README.md:287)" do
          glob = 'spec/fixtures/dir*'
          kwds, _, _ = parser.parse(["dirs:", glob])
          expect(kwds.dirs.sort).to eq(%w[spec/fixtures/dir1 spec/fixtures/dir2])
        end
      end
    end
  end
end