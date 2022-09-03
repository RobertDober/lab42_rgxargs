# frozen_string_literal: true

require 'ostruct'
RSpec.describe OpenStruct do
  describe "deconstruct keys" do
    let(:empty) { described_class.new }
    let(:singleton) { described_class.new(a: 1) }
    let(:subject) { described_class.new(a: 1, b: 2, c: 3) }

    context "matches" do
      it "deconstructs empty" do
        empty => {}
      end

      it "deconstructs singleton" do
        singleton => {a: }
        expect(a).to eq(1)
      end

      it "deconstructs subject" do
        subject => {a:, b:, c:}
        expect(a + b + c).to eq(6)
      end
    end

    context "missmatches" do
      it "does not deconstruct empty" do
        expect do
          empty => a:
        end.to raise_error(NoMatchingPatternError)
      end

      it "does not deconstruct singleton" do
        expect do
          singleton => :b
        end.to raise_error(NoMatchingPatternError)
      end

      it "does not deconstruct subject" do
        expect do
          subject => {a:, b:, **nil}
        end.to raise_error(NoMatchingPatternError)
      end
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
