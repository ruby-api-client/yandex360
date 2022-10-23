# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#groups.create" do
  let(:org_id) { "1234567" }
  let(:name) { "Hotline" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/create") do
        @yandex360.groups.create org_id: org_id, name: name
      end
    end

    it { expect(resp).to be_an Yandex360::Group }
  end
end

RSpec.describe "#groups.update" do
  let(:name) { "Hotline 247" }
  let(:org_id) { "1234567" }
  let(:group_id) { "19" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/update") do
        @yandex360.groups.update org_id: org_id, group_id: group_id, name: name
      end
    end

    it { expect(resp).to be_an Yandex360::Group }
  end
end

RSpec.describe "#groups.params" do
  let(:org_id) { "1234567" }
  let(:group_id) { "19" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/params") do
        @yandex360.groups.params org_id: org_id, group_id: group_id
      end
    end

    it { expect(resp).to be_an Yandex360::Group }
  end
end

RSpec.describe "#groups.list" do
  let(:org_id) { "1234567" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/list") do
        @yandex360.groups.list org_id: org_id
      end
    end

    it { expect(resp).to be_an Yandex360::Collection }
    it { expect(resp.data.first).to be_an Yandex360::Group }
  end
end

RSpec.describe "#groups.add_user" do
  let(:org_id) { "1234567" }
  let(:user_id) { "987654321" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/add_user") do
        @yandex360.groups.add_user org_id: org_id, group_id: "19", user_id: user_id, type: "user"
      end
    end

    it { expect(resp).to be_an Yandex360::Group }
    it { expect(resp.added).to be true }
    it { expect(resp.id).to eq user_id }
    it { expect(resp.type).to eq "user" }
  end
end

RSpec.describe "#groups.users" do
  let(:org_id) { "1234567" }
  let(:group_id) { "19" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/users") do
        @yandex360.groups.users org_id: org_id, group_id: group_id
      end
    end

    it { expect(resp).to be_an Yandex360::Collection }
    it { expect(resp.data.first).to be_an Yandex360::User }
  end
end

RSpec.describe "#groups.delete_user" do
  let(:org_id) { "1234567" }
  let(:user_id) { "987654321" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/delete_user") do
        @yandex360.groups.delete_user org_id: org_id, group_id: "19", type: "user", user_id: user_id
      end
    end

    it { expect(resp.deleted).to be true }
    it { expect(resp.type).to eq "user" }
    it { expect(resp.id).to eq user_id }
  end
end

RSpec.describe "#groups.delete" do
  let(:org_id) { "1234567" }
  let(:group_id) { 19 }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("groups/delete") do
        @yandex360.groups.delete org_id: org_id, group_id: group_id
      end
    end

    it { expect(resp).to be_an Yandex360::Group }
    it { expect(resp.removed).to eq true }
    it { expect(resp.id).to eq group_id }
  end
end
