# DO NOT EDIT!!!
# This file was generated from "README.md" with the speculate_about gem, if you modify this file
# one of two bad things will happen
# - your documentation specs are not correct
# - your modifications will be overwritten by the speculate rake task
# YOU HAVE BEEN WARNED
RSpec.describe "README.md" do
  # README.md:21
  context "Setup for speculations" do
    # README.md:24
    let(:parser) {Lab42::Rgxargs.new}

    private
    def os(**kwds); L42::Map.new(**kwds) end
    # README.md:34
    context "No Config Out Of The Box" do
      it "I can parse ruby syntax based arguments (README.md:37)" do
        kwds, positionals, _errors = parser.parse(%w{a: 42 hello :b})
        expect(kwds).to eq(os(a: "42", b: true))
        expect(positionals).to eq(%w{hello})
      end
      it "the only error one can get with this null configuration is a missing value for trailing keyword arg (README.md:44)" do
        kwds, _, errors = parser.parse(%w{a: b: a:})
        expect(kwds).to eq(os(a: "b:"))
        expect(errors).to eq([[:missing_required_value, :a]])
      end
      it "for those who prefer to use pattern matching, like YHS (README.md:51)" do
        parser.parse(%w{a: b: a:}) => {a:}, [], errors
        expect(a).to eq("b:")
        expect(errors).to eq([[:missing_required_value, :a]])
      end
      it "unprovided arguments equal nil (README.md:58)" do
        expect(parser.parse([]).first.verbose).to be_nil
      end
    end
    # README.md:62
    context "Hash instead of L42::Map?" do
      # README.md:69
      let(:parser) { Lab42::Rgxargs.new(l42_map: false) }
      let(:posix) { Lab42::Rgxargs.new(l42_map: false, posix: true) }
      it "we just get a good ol' Hash ;) (README.md:75)" do
        parser.parse(%w[a: 1 b: 2]) => {a: alpha, b: beta}, _, _
        expect(alpha.to_i + beta.to_i).to eq(3)

        posix.parse(%w[-n --a=1]) => {a: alpha, n: true}, _, _
        expect(alpha).to eq("1")
      end
    end
    # README.md:83
    context "And What About Posix?" do
      # README.md:86
      let(:parser) { Lab42::Rgxargs.new(posix: true) }
      it "I can parse posix style options (README.md:91)" do
        kwds, positionals, _errors = parser.parse(%w{-xy --a=42 --hello=b hello})
        expect(kwds).to eq(os(x:true, y:true, a: "42", hello: "b"))
        expect(positionals).to eq(%w{hello})
      end
      it "we can use `--` to get positionals with leading `-`s and we also accept long flags (therefore the = is needed for values) (README.md:98)" do
        kwds, positionals, _errors = parser.parse(%w{-xy --a -- --hello=b})
        expect(kwds).to eq(os(x:true, y:true, a: true))
        expect(positionals).to eq(%w{--hello=b})
      end
    end
    # README.md:108
    context "Conversion Of Keyword Parameters" do
      # README.md:111
      before { parser.add_conversion(:lower, %r{\A([-+]?\d+)}, &:to_i) }
      it "the parsed value for the `lower` argument will be an `Integer`, while the other parsed values remain `Strings` (README.md:116)" do
        expect(parser.parse(%w[lower: 42 upper: 43]).first)
        .to eq(os(lower: 42, upper: "43"))
      end
      # README.md:121
      context "Withe predefined matchers" do
        it "such common converters are predefined of course, and thusly (README.md:124)" do
          parser.add_conversion(:alpha, :int)
          expect(parser.parse(%w[alpha: 42]).first)
          .to eq(os(alpha: 42))
        end
        it "you can see all predefined matchers as follows (README.md:131)" do
          predefined_matchers =
          %w[ existing_dirs int int_list int_range list range ]
          .join("\n\t")
          expect(parser.predefined_matchers).to eq(predefined_matchers)
        end
        it "We can also just pass in the converter without a guard (README.md:139)" do
          parser.add_conversion(:maybe_int, &:to_i)
          expect(parser.parse(%w[maybe_int: fourtytwo]).first)
          .to eq(os(maybe_int: 0))
        end
        it "converters with guards do return meaningful error messages (README.md:147)" do
          _, _, errors = parser.parse(%w{lower: hello})
          expect(errors).to eq([[:syntax_error, :lower, "hello does not match (?-mix:\\A([-+]?\\d+))"]])
        end
      end
    end
    # README.md:152
    context "General Syntax" do
      it "therefore (README.md:159)" do
        parser.add_syntax(%r{(\d+)\.\.(\d+)}, ->(*captures){ Range.new(*captures.map(&:to_i)) })
        _, my_range, _ = parser.parse(%w{1..3})
        expect(my_range.first).to eq(1..3)
      end
      it "we have some predefined syntaxes, of course (README.md:166)" do
        parser.add_syntax(:range)
        _, my_range, _ = parser.parse(%w{1..3})
        expect(my_range.first).to eq(1..3)
      end
      it "they are of course applied to **all** arguments, e.g. (README.md:173)" do
        parser.add_syntax(:range)
        parser.add_syntax(:list)
        _, pos , _ = parser.parse(%w{ 1,2 1..3 42})
        list, range, answer = pos
        expect(list).to eq(%w{1 2}) # N.B. Strings
        expect(range).to eq(1..3)
        expect(answer).to eq(%w{42})  # N.B. Strings
      end
      it "there is a special `int_list` converter available (README.md:185)" do
        parser.add_syntax(:int_list)
        _, list, _ = parser.parse(%w{1,2,4})
        expect(list.first).to eq([1,2,4])
      end
      it "Of course a `add_syntax` (for positionals) and  `add_conversion` (for keywords) can be mixed using the same converters under the hood (README.md:192)" do
        parser.add_conversion([:lower, :upper], :int)
        parser.add_syntax([:int, :range])

        kwds, pos, _ = parser.parse(%w[42 lower: 1 upper: 2 1..3])
        expect(kwds).to eq(os(lower: 1, upper: 2))
        expect(pos).to eq([42, 1..3])
      end
    end
    # README.md:202
    context "Giving Names to Syntaxes" do
      it "therefore we have (README.md:211)" do

        parser.add_syntax(%r{\A(\d+:\d+:\d+)\z}, ->(ts){ ts }, as: :timestamp)
        kwds, positionals, _ = parser.parse(%w[foo 20:10:10])
        expect(kwds.timestamp).to eq("20:10:10")
        expect(positionals).to eq(%w{foo})
      end
      it "for more complex possibilities of timestamps one can use a little DSL (README.md:220)" do

        parser.define_arg(:timestamp) do
        syntax(%r{\A(\d+:\d+)\z}, &:itself)
        syntax(%r{\A(\d{6,})\z}) { |capture| capture.to_i }
        end

        kwds, _, _ = parser.parse(%w[123456])
        expect(kwds.timestamp).to eq(123456)
      end
    end
    # README.md:231
    context "Constraints" do
      # README.md:233
      context "Allowing Keyword Params" do
        it "Allowing keywords means, all others are forbidden (README.md:236)" do
          parser.allow_kwds(:version)

          _, _, errors = parser.parse(%w[vision: 41])
          expect(errors) == [[:unauthorized_kwd, :vision]]
        end
        it "the allowed work as expected (README.md:244)" do
          parser.allow_kwds(:version)

          kwds, _, errors = parser.parse(%w[version: 42])
          expect(errors).to be_empty
          expect(kwds.version).to eq("42")
        end
      end
    end
    # README.md:252
    context "Require Keyword Params" do
      it "if required keywords are absent... (README.md:255)" do
        parser.require_kwds(:from)
        parser.add_conversion(:to, :int, :required)

        _, _, errors = parser.parse(%w[version: 42])
        expect(errors).to eq([
        [:required_kwd_missing, :from],
        [:required_kwd_missing, :to]
        ])
      end
      it "if they are present... (README.md:267)" do
        parser.require_kwds(:from)
        parser.add_conversion(:to, :int, :required)

        kwds, _, errors = parser.parse(%w[to: 2 from: 1])
        expect(errors).to be_empty
        expect(kwds).to eq(os(from: "1", to: 2))
      end
    end
    # README.md:276
    context "Syntactic Sugar" do
      # README.md:281
      let :parser do
      Lab42::Rgxargs.new do
      needs  :n, &:to_i
      allows :m, &:to_i
      end
      end
      it "the conversion works of course as expected (README.md:291)" do
        kwds, _, _ = parser.parse(%w[n: alpha, m: 42])
        expect(kwds).to eq(os(n: 0, m: 42))
      end
      # README.md:296
      context "Using predefined matches in the DSL" do
        # README.md:299
        let :parser do
        Lab42::Rgxargs.new do
        allows :dirs, :existing_dirs
        end
        end
        it "we can parse the keyword arguments with existing dirs w/o an error (README.md:308)" do
          glob = 'spec/fixtures/dir*'
          kwds, _, _ = parser.parse(["dirs:", glob])
          expect(kwds.dirs.sort).to eq(%w[spec/fixtures/dir1 spec/fixtures/dir2])
        end
      end
    end
  end
end