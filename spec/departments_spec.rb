# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#departments.list" do
  let(:org_id) { "1234567" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/list") do
        @yandex360.departments.list(org_id: org_id)
      end
    end

    it { expect(resp).to be_a Yandex360::Collection }
    it { expect(resp.data.first).to be_an Yandex360::Department }
  end
end

RSpec.describe "#departments.create" do
  let(:org_id) { "1234567" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/create") do
        @yandex360.departments.create(org_id: org_id, name: "Support", parent_id: 1)
      end
    end

    it { expect(resp).to be_an Yandex360::Department }
  end
end

RSpec.describe "#departments.update" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }
  let(:parent_id) { "1" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/update") do
        @yandex360.departments.update(
          org_id: org_id,
          dep_id: dep_id,
          parent_id: parent_id,
          description: "Yandex360",
          name: "Support Team",
          label: "support-team"
        )
      end
    end

    it { expect(resp).to be_an Yandex360::Department }
  end
end

RSpec.describe "#departments.info" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/info") do
        @yandex360.departments.info(dep_id: dep_id, org_id: org_id)
      end
    end

    it { expect(resp).to be_an(Yandex360::Department) }
  end
end

RSpec.describe "#departments.add_alias" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }
  let(:name)   { "support-team" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/add_alias") do
        @yandex360.departments.add_alias(org_id: org_id, dep_id: dep_id, name: name)
      end
    end

    it { expect(resp).to be_an Yandex360::DepartmentAlias }
    it { expect(resp.aliases.first).to eq name }
  end
end

RSpec.describe "#departments.delete_alias" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }
  let(:name)   { "support-team" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/delete_alias") do
        @yandex360.departments.delete_alias(org_id: org_id, dep_id: dep_id, name: name)
      end
    end

    it { expect(resp).to be_an Yandex360::Object }
    it { expect(resp.removed).to be true }
    it { expect(resp.alias).to eq name }
  end
end

RSpec.describe "#departments.delete" do
  let(:org_id) { "1234567" }
  let(:dep_id) { "13" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("departments/delete") do
        @yandex360.departments.delete(org_id: org_id, dep_id: dep_id)
      end
    end

    it { expect(resp).to be_an(Yandex360::Object) }
  end

  context "with error" do
    subject(:resp) do
      VCR.use_cassette("departments/delete_error") do
        @yandex360.departments.delete(org_id: org_id, dep_id: dep_id)
      end
    end

    it { expect { resp }.to raise_error(Yandex360::Error, /No results/) }
  end
end
