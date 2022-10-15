# frozen_string_literal: true

require "spec_helper"
require "yandex360"

RSpec.describe "#users.list" do
  let(:org_id) { "1234567" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/list") do
        @yandex360.users.list(org_id: org_id)
      end
    end

    it { expect(resp).to be_an(Yandex360::Collection) }
    it { expect(resp.data.first).to be_an(Yandex360::User) }
  end

  context "with error" do
    let(:org_id) { "3287461283" }
    subject(:resp) do
      VCR.use_cassette("users/list_error") do
        @yandex360.users.list(org_id: org_id)
      end
    end

    it { expect { resp }.to raise_error(Yandex360::Error, /not allowed/) }
  end
end

RSpec.describe "#users.add" do
  let(:org_id) { "1234567" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/add") do
        @yandex360.users.add(
          org_id: org_id,
          dep_id: 1,
          about: "Yandex360",
          name: {
            first: "Ivan",
            last: "Ivanov",
            middle: "Ruby"
          },
          nickname: "yandex360",
          password: "W!846f456678"
        )
      end
    end
    it { expect(resp).to be_an(Yandex360::User) }
    it { expect(resp.name.first).to eq "Ivan" }
    it { expect(resp.about).to eq "Yandex360" }
  end
end

RSpec.describe "#users.update" do
  let(:user_id) { "1130000061922106" }
  let(:org_id)  { "1234567" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/update") do
        @yandex360.users.update(
          org_id: org_id,
          user_id: user_id,
          about: "Yandex360 - Ruby API gem",
          name: {
            first: "Ruby",
            last: "gem",
            middle: "API"
          },
          nickname: "yandex360-ruby-api-client",
          password: "passswrrdwithstrrngscrrty"
        )
      end
    end
    it { expect(resp).to be_an(Yandex360::User) }
    it { expect(resp.id).to eq user_id }
    it { expect(resp.name.first).to eq "Ruby" }
    it { expect(resp.about).to eq "Yandex360 - Ruby API gem" }
  end
end

RSpec.describe "#users.add_alias" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }
  let(:user_alias) { "ruby_gem_api" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/add_alias") do
        @yandex360.users.add_alias org_id: org_id, user_id: user_id, user_alias: user_alias
      end
    end

    it { expect(resp).to be_an(Yandex360::User) }
    it { expect(resp.aliases.first).to eq user_alias }
  end
end

RSpec.describe "#users.delete_alias" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }
  let(:user_alias) { "ruby_gem_api" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/delete_alias") do
        @yandex360.users.delete_alias org_id: org_id, user_id: user_id, user_alias: user_alias
      end
    end

    it { expect(resp).to be_an(Yandex360::Alias) }
    it { expect(resp.alias).to eq user_alias }
    it { expect(resp.removed).to be(true) }
  end
end

RSpec.describe "#users.has2FA" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/has2FA") do
        @yandex360.users.has2FA? org_id: org_id, user_id: user_id
      end
    end

    it { expect(resp).to be(true).or be(false) }
  end
end

RSpec.describe "#users.get2FA" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/get2FA") do
        @yandex360.users.get2FA(org_id: org_id, user_id: user_id)
      end
    end

    it { expect(resp).to be_an(Yandex360::Object) }
    it { expect(resp.userId).to eq(user_id) }
    it { expect(resp.has2fa).to be(true).or be(false) }
  end

  context "with error" do
    subject(:resp) do
      VCR.use_cassette("users/get2FA_error") do
        @yandex360.users.get2FA(org_id: 123, user_id: 123)
      end
    end

    it { expect { resp }.to raise_error(Yandex360::Error, /not allowed/) }
  end
end

RSpec.describe "#users.has2FA" do
  let(:org_id) { "1234567" }
  let(:user_id) { "1130000018743049" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/has2FA") do
        @yandex360.users.has2FA? org_id: org_id, user_id: user_id
      end
    end

    it { expect(resp).to be(true).or be(false) }
  end
end

RSpec.describe "#users.info" do
  let(:org_id) { "1234567" }
  let(:user_id) { "987654321" }

  context "with params" do
    subject(:resp) do
      VCR.use_cassette("users/info") do
        @yandex360.users.info(org_id: org_id, user_id: user_id)
      end
    end

    it { expect(resp).to be_an(Yandex360::User) }
    it { expect(resp.name).to be_an(OpenStruct) }
    it { expect(resp.contacts).to be_an(Array) }
  end

  context "without params" do
    subject(:resp) do
      VCR.use_cassette("users_info") do
        @yandex360.users.info
      end
    end

    it { expect { resp }.to raise_error(ArgumentError) }
  end
end
