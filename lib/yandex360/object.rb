# frozen_string_literal: true

require "ostruct"

module Yandex360
  class Object < OpenStruct
    def initialize(attributes)
      super to_ostruct(attributes)
    end

    # Convert Array or Hash to OpenStruct
    def to_ostruct(obj)
      case obj
      when Hash
        return OpenStruct.new if obj.empty?
        OpenStruct.new(obj.transform_values { |val| to_ostruct(val) })
      when Array
        obj.map { |o| to_ostruct(o) }
      when nil
        nil
      else
        obj
      end
    end
  end
end
