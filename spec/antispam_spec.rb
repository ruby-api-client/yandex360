# frozen_string_literal: true

RSpec.describe "#anispam.create" do
  let(:org_id) { "1234567" }

  context "when create" do
    subject(:resp) do
      VCR.use_cassette("anispam/create") do
        @yandex360.antispam.create(org_id, "127.0.0.1", "172.0.1.10")
      end
    end

    it { expect(resp).to be_an Yandex360::AllowList }
  end
end

RSpec.describe "#anispam.list" do
  let(:org_id) { "1234567" }

  context "when list" do
    subject(:resp) do
      VCR.use_cassette("anispam/list") do
        @yandex360.antispam.list(org_id: org_id)
      end
    end

    it { expect(resp).to be_an Yandex360::AllowList }
  end
end

RSpec.describe "#anispam.delete" do
  let(:org_id) { "1234567" }

  context "when delete" do
    subject(:resp) do
      VCR.use_cassette("anispam/delete") do
        @yandex360.antispam.delete(org_id: org_id)
      end
    end

    it { expect(resp.status).to eq 200 }
  end
end
