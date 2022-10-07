# frozen_string_literal: true

module Yandex360
  class Collection
    attr_reader :data, :items, :total

    def self.from_response(response, key:, type:)
      body = response.body
      new(
        data: body[key].map {|attrs| type.new(attrs) },
        items: body["items"],
        total: body["total"]
      )
    end

    def initialize(data:, items:, total:)
      @data   = data
      @items  = items
      @total  = total
    end
  end
end
