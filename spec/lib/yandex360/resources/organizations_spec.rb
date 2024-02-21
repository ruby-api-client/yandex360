# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#orgs.list" do
  context "called" do
    subject(:resp) do
      VCR.use_cassette("orgs/list") do
        @yandex360.orgs.list
      end
      it { expect(resp).to be_an Yandex360::Organization }
    end
  end
end
