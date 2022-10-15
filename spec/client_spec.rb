# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe Yandex360::Client do
  describe "#client", :vcr do
    context "with valid token" do
      it do
        allow(described_class).to receive(:new)
          .with(token: ACCESS_TOKEN)
          .and_return(Yandex360::Client)
      end
    end

    context "without token" do
      it { expect { described_class.new }.to raise_error(ArgumentError) }
    end
  end
end

RSpec.describe "#VERSION" do
  it { expect(Yandex360::VERSION).to eq "1.1.1" }
end
