# frozen_string_literal: true

module Yandex360
  module ParamBuilder
    private

    def build_params(base_params, additional_params)
      params = base_params.dup
      additional_params.each {|param, value| params[param] = value }
      params
    end
  end
end
