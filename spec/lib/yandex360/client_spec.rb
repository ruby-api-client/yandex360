# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::Client do
  describe "#client" do
    context "with valid token" do
      it "creates client successfully" do
        client = described_class.new(token: "valid_token")
        expect(client).to be_a(Yandex360::Client)
        expect(client.token).to eq("valid_token")
      end
    end

    context "without token" do
      it { expect { described_class.new }.to raise_error(ArgumentError) }
    end
  end
end

RSpec.describe "#VERSION" do
  it { expect(Yandex360::VERSION).to eq "1.1.3" }
end
