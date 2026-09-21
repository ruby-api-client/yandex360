# frozen_string_literal: true

module Yandex360
  # The work the Railtie does, kept here as plain methods so it can be tested
  # without booting an application. The Railtie itself is only wiring.
  module Rails
    # ActiveSupport's own convention is event.library, as in sql.active_record,
    # so an APM recognises this without being told about it.
    EVENT_NAME = "request.yandex360"

    class << self
      # Copies config.yandex360 into the gem's own configuration. Values left
      # unset in the application are not touched, so the gem's defaults stand.
      def apply_configuration(options, logger: nil)
        Yandex360.configure do |config|
          Configuration::SETTINGS.each do |setting|
            value = options[setting]
            config.public_send("#{setting}=", value) unless value.nil?
          end

          # Rails already has somewhere for this to go, so use it unless the
          # application said otherwise.
          config.logger ||= logger
        end
      end

      # Republishes the gem's events through ActiveSupport::Notifications.
      # Returns the subscriber so a caller can undo it.
      def bridge_instrumentation(notifications)
        Yandex360.on(:request) do |event|
          notifications.instrument(EVENT_NAME, event.to_h)
        end
      end
    end
  end
end
