# frozen_string_literal: true

require "yandex360/rails"

module Yandex360
  # Loaded only when Rails is present. Everything it does is available without
  # it: this saves an application from writing the same initializer.
  #
  #   # config/application.rb, or an initializer
  #   config.yandex360.token = ENV.fetch("YA360_TOKEN")
  #   config.yandex360.timeout = 60
  #   config.yandex360.instrument = false   # to skip the notifications bridge
  #
  # Requests are published as "request.yandex360" through
  # ActiveSupport::Notifications, and Rails.logger is used unless the
  # application sets a logger of its own.
  class Railtie < ::Rails::Railtie
    config.yandex360 = ActiveSupport::OrderedOptions.new

    initializer "yandex360.configure" do |app|
      Yandex360::Rails.apply_configuration(app.config.yandex360, logger: ::Rails.logger)
    end

    initializer "yandex360.instrumentation" do |app|
      unless app.config.yandex360.instrument == false
        Yandex360::Rails.bridge_instrumentation(ActiveSupport::Notifications)
      end
    end
  end
end
