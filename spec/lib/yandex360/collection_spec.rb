# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::Collection do
  subject(:collection) { described_class.new(data: data, items: 3, total: 42) }

  let(:data) { %w[first second third] }

  describe "#first" do
    it "returns the leading element without an argument" do
      expect(collection.first).to eq("first")
    end

    it "returns the leading n elements with an argument" do
      expect(collection.first(2)).to eq(%w[first second])
    end

    context "when empty" do
      let(:data) { [] }

      it "returns nil without an argument" do
        expect(collection.first).to be_nil
      end

      it "returns an empty array with an argument" do
        expect(collection.first(2)).to eq([])
      end
    end
  end

  describe "#last" do
    it "returns the trailing element without an argument" do
      expect(collection.last).to eq("third")
    end

    it "returns the trailing n elements with an argument" do
      expect(collection.last(2)).to eq(%w[second third])
    end

    context "when empty" do
      let(:data) { [] }

      it "returns nil without an argument" do
        expect(collection.last).to be_nil
      end
    end
  end

  describe "Enumerable" do
    it "iterates over the underlying data" do
      expect(collection.map(&:upcase)).to eq(%w[FIRST SECOND THIRD])
    end

    it "exposes size, length and count" do
      expect([collection.size, collection.length, collection.count]).to all(eq(3))
    end

    it "reads by index" do
      expect(collection[1]).to eq("second")
    end

    it "reports emptiness" do
      expect(collection).not_to be_empty
    end

    it "keeps the totals reported by the API" do
      expect([collection.items, collection.total]).to eq([3, 42])
    end
  end
end
