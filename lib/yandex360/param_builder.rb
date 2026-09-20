# frozen_string_literal: true

module Yandex360
  module ParamBuilder
    private

    # Extra keywords are merged over the fields a method fills in itself.
    # A collision means the caller passed the same field twice, usually in the
    # other naming style, and silently keeping one of the two is how a value
    # disappears without a word. Say so instead.
    def build_params(base_params, additional_params)
      conflicts = base_params.keys & additional_params.keys
      raise ArgumentError, "Duplicate parameters: #{conflicts.join(', ')}" unless conflicts.empty?

      base_params.merge(additional_params)
    end
  end
end
