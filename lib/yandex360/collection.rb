# frozen_string_literal: true

module Yandex360
  class Collection
    include Enumerable

    attr_reader :data, :items, :total

    def self.from_response(response, key:, type:)
      body = response.body
      new(
        data: body[key]&.map { |attrs| type.new(attrs) } || [],
        items: body["items"] || 0,
        total: body["total"] || 0
      )
    end

    def initialize(data:, items:, total:)
      @data   = data
      @items  = items
      @total  = total
    end

    def each(&block)
      data.each(&block)
    end

    def size
      data.size
    end
    alias length size
    alias count size

    def empty?
      data.empty?
    end

    def first(n = nil)
      n ? data.first(n) : data.first
    end

    def last(n = nil)
      n ? data.last(n) : data.last
    end

    def [](index)
      data[index]
    end
  end
end
