# frozen_string_literal: true

module Yandex360
  # A single page of records, plus the means to walk the rest.
  #
  # The API reports pagination as page, pages, perPage and total. A collection
  # built with a pager block can fetch the following pages on demand; one built
  # without it behaves as a single page.
  class Collection
    include Enumerable

    attr_reader :data, :items, :total, :page, :pages, :per_page, :next_page_token

    def self.from_response(response, key:, type:, &pager)
      body = response.body
      records = body[key]&.map {|attrs| type.new(attrs) } || []

      new(
        data: records,
        # The API does not return an "items" field; it is read here only for
        # callers that already relied on it, and falls back to the page size.
        items: body["items"] || records.size,
        total: body["total"] || 0,
        page: body["page"],
        pages: body["pages"] || derive_pages(body),
        per_page: body["perPage"],
        # Audit log endpoints page by opaque token instead of page number.
        next_page_token: body["nextPageToken"],
        pager: pager
      )
    end

    # Some endpoints report total and perPage but not pages.
    def self.derive_pages(body)
      total = body["total"]
      per_page = body["perPage"]
      return nil if total.nil? || per_page.nil? || per_page.to_i.zero?

      (total.to_f / per_page.to_i).ceil
    end
    private_class_method :derive_pages

    def initialize(data:, items:, total:, page: nil, pages: nil, per_page: nil,
                   next_page_token: nil, pager: nil)
      @data            = data
      @items           = items
      @total           = total
      @page            = page
      @pages           = pages
      @per_page        = per_page
      @next_page_token = next_page_token
      @pager           = pager
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
      idx ? data.first(idx) : data.first
    end

    def last(idx=nil)
      idx ? data.last(idx) : data.last
    end

    def [](index)
      data[index]
    end

    def last_page?
      next_cursor.nil?
    end

    # What identifies the following page: an opaque token where the endpoint
    # issues one, otherwise the next page number. Nil on the last page.
    def next_cursor
      return next_page_token unless next_page_token.nil? || next_page_token.empty?
      return nil if page.nil? || pages.nil? || page >= pages

      page + 1
    end

    # The next page, or nil when this is the last one or the collection was
    # built without a pager.
    def next_page
      return nil if @pager.nil? || last_page?

      @pager.call(next_cursor)
    end

    # Yields this collection and each following one. Without a block, returns
    # an enumerator.
    def each_page
      return enum_for(:each_page) unless block_given?

      collection = self
      while collection
        yield collection
        collection = collection.next_page
      end
    end

    # Every record across every page, fetched lazily as the pages are consumed.
    def auto_paginate(&block)
      return enum_for(:auto_paginate) unless block

      each_page {|collection| collection.each(&block) }
    end
  end
end
