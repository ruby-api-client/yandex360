# frozen_string_literal: true

module Yandex360
  # Base for every response object.
  #
  # The parsed body is kept as it arrived and declared fields are read from it
  # through real methods, so a misspelled attribute raises NoMethodError rather
  # than quietly returning nil, and a field the API adds tomorrow is still
  # reachable through #[] without waiting for a release.
  #
  # Declared names are snake_case. Where the API spells a field differently the
  # original name is kept as a deprecated alias; see #attribute.
  class Record
    class << self
      # Declares a reader. `from` gives the key in the response when it differs
      # from the Ruby name, and that original spelling stays available as a
      # deprecated alias so existing code keeps working through 3.x.
      def attribute(name, from: nil)
        key = (from || name).to_s
        attribute_keys[name.to_sym] = key

        define_method(name) { self[key] }
        return if key == name.to_s

        define_method(key) do
          warn "[yandex360] #{self.class}##{key} is deprecated, use ##{name}", uplevel: 1
          self[key]
        end
      end

      def attribute_keys
        @attribute_keys ||=
          superclass.respond_to?(:attribute_keys) ? superclass.attribute_keys.dup : {}
      end
    end

    def initialize(data)
      @data = data.is_a?(Hash) ? data : {}
      @wrapped = {}
    end

    # Reads any key, declared or not. Nested hashes and arrays of hashes come
    # back wrapped, so user.name.first and rule.actions.first.action work.
    def [](key)
      key = key.to_s
      return @wrapped[key] if @wrapped.key?(key)

      @wrapped[key] = wrap(@data[key])
    end

    def to_h
      @data
    end

    def key?(key)
      @data.key?(key.to_s)
    end

    def ==(other)
      other.is_a?(self.class) && other.to_h == to_h
    end
    alias eql? ==

    def hash
      [self.class, @data].hash
    end

    def inspect
      "#<#{self.class.name} #{@data.keys.join(', ')}>"
    end

    private

    def wrap(value)
      case value
      when Hash  then Response.new(value)
      when Array then value.map {|item| wrap(item) }
      else value
      end
    end
  end

  # For a reply with no documented entity behind it, such as {"added": true},
  # and for nested structures, parts of which the reference leaves as
  # free-form JSON. Readers come from the keys that arrived rather than from a
  # declaration, so there is nothing to keep in sync, and #[] still reads
  # anything.
  class Response < Record
    def initialize(data)
      super
      to_h.each_key do |key|
        next unless key.is_a?(String) && key.match?(/\A[a-zA-Z_]\w*\z/)
        # Never shadow a real method such as to_h or hash; those keys stay
        # reachable through #[].
        next if self.class.method_defined?(key) || singleton_class.method_defined?(key)

        define_singleton_method(key) { self[key] }
      end
    end

    # Readers are defined above for the keys that arrived, so reaching here
    # means the key is absent. Say which ones are there rather than leaving the
    # caller to guess.
    def method_missing(name, *args)
      return super unless args.empty?

      raise NoMethodError, "#{name} is not present in this response; " \
                           "readable keys are #{to_h.keys.join(', ')}, " \
                           "and any key can be read with []"
    end

    def respond_to_missing?(_name, _include_private=false)
      false
    end
  end
end
