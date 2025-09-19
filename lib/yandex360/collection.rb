# frozen_string_literal: true

module Yandex360
  class Collection
    include Enumerable

    attr_reader :data, :items, :total

    def self.from_response(response, key:, type:)
      body = response.body
      new(
        data: body[key]&.map {|attrs| type.new(attrs) } || [],
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

    def first(idx=nil)
      n ? data.first(idx) : data.first
    end

    def last(idx=nil)
      n ? data.last(idx) : data.last
    end

    def [](index)
      data[index]
    end
  end
end
